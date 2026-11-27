# frozen_string_literal: true

require 'json'
require 'uri'

module Staging
  # Detects, and fails the run on, any request from a run against a *deployed*
  # environment that could have changed it.
  #
  # It cannot prevent one. The staging environment shares its S3 bucket with
  # production, so a stray form submission in a remote spec would upload a file
  # into live content. Chrome reports every request it issues to the performance
  # log; after each example this module parses those entries and raises
  # `WriteAttempted` naming each offending request, which fails the example (and
  # therefore the run) — after the request has already been sent. What keeps the
  # run read-only is that the journeys only drive read-only page objects; this
  # guard is the tripwire that reports when one does not.
  #
  # Two kinds of request fail the run:
  #
  # * any request that is not a GET, except the tolerated ones below;
  # * a GET to a path known to have side effects (`SIDE_EFFECT_GET_PATHS`): GET is
  #   not read-only in this app. `GET /admin/cms/transcripts/:id/sync` enqueues a
  #   billable Azure speech-to-text job that rewrites the transcript's lines, and
  #   `GET /users/sign_out` (Devise's `sign_out_via = :get`) ends the session.
  #   This is also why authenticated journeys must never walk links.
  #
  # Four kinds of non-GET request are tolerated, because they cannot write to the
  # environment or its bucket:
  #
  # * session establishment (`SESSION_PATHS`: the `/users/sign_in` POST) — the
  #   only way to reach the authenticated journeys, and the reason
  #   `authenticated_spec.rb` can use the real form rather than `sign_in_as`;
  # * two same-origin POSTs that only read (`READ_ONLY_POST_PATHS`): the editor
  #   asks who is signed in, and the institution selector asks for an
  #   institution's collections. Rejecting them fails every healthy editor run;
  # * the report-only CSP endpoint (config/initializers/content_security_policy.rb
  #   sets `report_uri`), which the *browser* posts to when a page violates the
  #   policy. Failing on it would report a deployment's CSP bugs as writes;
  # * analytics beacons (Google Tag Manager is rendered by the `application_v2`
  #   and `admin` layouts), which are browser-generated and outside the
  #   deployment entirely. Only a POST counts as a beacon: any other verb
  #   aimed at those hosts is not one, and is reported.
  #
  # Everything else — including any S3 host, so a pre-signed bucket upload cannot
  # go unreported — raises.
  module ReadOnlyGuard
    WriteAttempted = Class.new(StandardError)

    GET = 'GET'
    REQUEST_WILL_BE_SENT = 'Network.requestWillBeSent'

    # The sign-in POST is the only session request a run may send, and the only way
    # to reach the authenticated journeys. `/users/sign_out` is deliberately absent:
    # by either verb it ends the session, so a GET fails through the list below and
    # anything else raises.
    SESSION_PATHS = %w[/users/sign_in].freeze
    CSP_REPORT_PATH = '/csp-violation-report-endpoint'
    # POSTs whose actions only read: `AuthenticationController#authenticate`
    # (the editor calls it as it boots) and `CollectionsController#list`
    # (app/assets/javascripts/collections.js). Matched against the path of a
    # request to the deployment, so a third-party `/authenticate` is still a write.
    READ_ONLY_POST_PATHS = [%r{\A/authenticate(\.json)?\z}, %r{\A/collections/list(\.json)?\z}].freeze
    ANALYTICS_HOSTS = %w[google-analytics.com googletagmanager.com].freeze
    # GETs that change the deployment or the session (see above), matched
    # against the path of a request to the deployment (to any host when no target
    # is given), so a third-party `/sync` endpoint is not mistaken for one. The
    # optional format suffix and trailing slash are the variants Rails routes
    # accept, and the link walker uses these same patterns to decide what is safe.
    SIDE_EFFECT_GET_PATHS = [%r{/sync(?:\.\w+)?/?\z}, %r{\A/users/sign_out(?:\.\w+)?/?\z}].freeze

    # One request Chrome reported.
    class Attempt
      attr_reader :method, :url

      def initialize(method:, url:)
        @method = method
        @url = url
      end

      def origin = [uri&.scheme, uri&.host, uri&.port]

      def path = uri&.path.to_s

      def host = uri&.host.to_s

      def to_s = "#{method} #{url}"

      private

      def uri
        @uri ||= URI.parse(url)
      rescue URI::InvalidURIError
        nil
      end
    end

    module_function

    # Raises `WriteAttempted` if any recorded request is a non-GET (other than
    # the tolerated writes above) or a GET to a side-effecting path. `logs` is the
    # array of entries `browser.logs.get(:performance)` returns; each entry's
    # `message` is the JSON Chrome logged. Returns nil when the run was read-only.
    def assert_read_only!(logs, target: nil)
      offending = requests(logs).select { |request| offending?(request, target) }
      return nil if offending.empty?

      raise WriteAttempted, failure_message(offending)
    end

    # Reads and clears the browser's performance log, then checks it. Skipped
    # when the example never drove a browser: no requests can have been issued.
    def check!(page, target: nil)
      return nil unless browser_started?(page)

      assert_read_only!(performance_logs(page), target: target)
    end

    # Capybara::Selenium::Driver#browser memoises the browser and only starts
    # Chrome on the first command, so the memo is read instead of #browser:
    # calling #browser would launch a browser for an example that never visited.
    def browser_started?(page)
      driver = page.driver
      driver.respond_to?(:browser) && !driver.instance_variable_get(:@browser).nil?
    end

    def performance_logs(page) = page.driver.browser.logs.get(:performance).map(&:message)

    # Every request the log recorded, in the order Chrome issued them.
    def requests(logs)
      Array(logs).filter_map do |entry|
        request = request_of(entry)
        next if request.nil?

        method = request['method'].to_s.upcase
        url = request['url'].to_s
        next if method.empty? || url.empty?

        Attempt.new(method: method, url: url)
      end
    end

    def offending?(request, target)
      return side_effect_get?(request, target) if request.method == GET

      !tolerated?(request, target)
    end

    def side_effect_get?(request, target)
      return false unless target.nil? || same_origin?(request, target)

      SIDE_EFFECT_GET_PATHS.any? { |pattern| pattern.match?(request.path) }
    end

    # The only non-GETs a run may send: session establishment, analytics beacons, and the two
    # read-only POSTs, which must also be to this deployment. A beacon is a POST, so any other
    # verb aimed at an analytics host falls through and is reported.
    def tolerated?(attempt, target)
      return true if attempt.method == 'POST' && (tolerated_post?(attempt, target) || analytics_request?(attempt))
      return false unless attempt.method == 'POST' && same_origin?(attempt, target)

      READ_ONLY_POST_PATHS.any? { |pattern| pattern.match?(attempt.path) }
    end

    def tolerated_post?(attempt, target)
      return false unless attempt.method == 'POST' && same_origin?(attempt, target)

      SESSION_PATHS.include?(attempt.path) || attempt.path == CSP_REPORT_PATH
    end

    def same_origin?(attempt, target)
      origin = parse(target)
      !origin.nil? && origin == attempt.origin
    end

    def analytics_request?(attempt)
      ANALYTICS_HOSTS.any? { |host| attempt.host == host || attempt.host.end_with?(".#{host}") }
    end

    def failure_message(requests)
      listing = requests.map { |request| "  #{request}" }.join("\n")

      <<~MESSAGE
        Read-only staging verification sent #{requests.size} request(s) that can change the deployment:

        #{listing}

        Only GETs without side effects are allowed, plus the session, CSP-report and
        read-only POSTs listed above: the staging environment shares
        its S3 bucket with production, so a write from this suite can corrupt live
        content, and some GETs (#{SIDE_EFFECT_GET_PATHS.map(&:inspect).join(', ')})
        enqueue paid jobs or end the session. Drive the environment through
        read-only page objects (spec/staging/smoke_spec.rb), keep administration to
        plain page loads (spec/staging/authenticated_spec.rb), and never walk links
        while signed in.
      MESSAGE
    end

    def request_of(entry)
      message = parsed_message(entry)
      return nil unless message && message['method'] == REQUEST_WILL_BE_SENT

      request = message.dig('params', 'request')
      request.is_a?(Hash) ? request : nil
    end

    def parsed_message(entry)
      raw = raw_message(entry)
      return nil if raw.nil?

      parsed = JSON.parse(raw)
      return nil unless parsed.is_a?(Hash)

      message = parsed['message']
      message.is_a?(Hash) ? message : nil
    rescue JSON::ParserError, TypeError
      nil
    end

    # Chrome reports one JSON document per entry. The guard accepts the entry as
    # Selenium hands it over (a LogEntry), the raw message the entry carries (what
    # `check!` reads, and what Chrome actually writes), or a hash with a `message`
    # key.
    def raw_message(entry)
      return entry if entry.is_a?(String)
      return entry.message if entry.respond_to?(:message)

      entry[:message] || entry['message'] if entry.respond_to?(:[])
    end

    def parse(url)
      return nil if url.nil?

      uri = URI.parse(url.to_s)
      [uri.scheme, uri.host, uri.port]
    rescue URI::InvalidURIError
      nil
    end
  end
end
