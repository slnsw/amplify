# frozen_string_literal: true

require 'uri'
require_relative 'read_only_guard'
require_relative 'report_formatter'

module Staging
  # Support for spec/staging: drives a *deployed* environment through a real
  # browser. These specs never touch ActiveRecord, factories or `sign_in_as`
  # (which authenticates the next request this process serves and cannot reach a
  # remote host); they drive the page objects in spec/support/page_objects and
  # assert on the rendered DOM.
  #
  # `.rspec` requires rails_helper for every spec file, so this suite still boots
  # Rails and `maintain_test_schema!` needs the local test database to exist; the
  # runner is executed from a development machine with Postgres available. Do not
  # restructure `.rspec` to avoid that boot: it would change how every other
  # spec loads.
  #
  # Environment:
  # * STAGING_URL (required to verify anything) — origin of the deployment, e.g.
  #   https://dev.amplify.gov.au; without it every staging example skips and the
  #   run exits 0.
  # * STAGING_EMAIL / STAGING_PASSWORD — a staff account; enables the dashboard and
  #   /admin/summary journeys in authenticated_spec.rb.
  # * STAGING_ADMIN_EMAIL / STAGING_ADMIN_PASSWORD — an admin account, for the
  #   /admin/reports and /admin/cms journeys. Use a dedicated account; those
  #   journeys only load pages and the read-only guard fails the run on anything else.
  TargetNotConfigured = Class.new(StandardError)

  # A dedicated driver: the local one maps the project CDN to a stub server, which
  # would hide what the deployment actually loads, and this one also asks Chrome
  # for the performance log the read-only guard parses.
  STAGING_DRIVER = :staging_chrome_headless

  module Target
    module_function

    def url
      ENV['STAGING_URL'].to_s.strip.chomp('/').presence
    end

    def configured? = url.present?

    def url! = url || raise(TargetNotConfigured, 'STAGING_URL is not set')

    def email = ENV['STAGING_EMAIL'].presence

    def password = ENV['STAGING_PASSWORD'].presence

    def credentials? = email.present? && password.present?

    # `/admin/reports` declares `before_action :authenticate_admin!`, and `/admin/cms`
    # authorises `Collection`, whose policy allows only an admin or a content editor.
    # Those journeys take their own admin account and skip without it; the dashboard
    # and `/admin/summary` only need staff, so the account above covers them.
    def admin_email = ENV['STAGING_ADMIN_EMAIL'].presence

    def admin_password = ENV['STAGING_ADMIN_PASSWORD'].presence

    def admin_credentials? = admin_email.present? && admin_password.present?
  end

  # The transcript a staging journey reads, standing in for the ActiveRecord
  # object `TranscriptEditorPage#visit_transcript` takes: it only ever asks a
  # transcript for its uid, its collection's uid and its institution's slug.
  class TranscriptRef
    Institution = Struct.new(:slug)
    Collection = Struct.new(:uid, :institution)

    attr_reader :uid, :collection

    def initialize(institution_slug:, collection_uid:, uid:)
      @uid = uid
      @collection = Collection.new(collection_uid, Institution.new(institution_slug))
    end

    def institution_slug = collection.institution.slug
  end

  # Helpers mixed into every `:staging` example.
  module Remote
    # The page's own navigation in either layout: the older `#primary-menu-container`
    # (public, institution and cms layouts) and the current `application_v2` header
    # (`shared/_header.html.erb`). `.menu_dropdown` is the account menu — it carries
    # `main_header__links` too — and is excluded because its provider buttons POST
    # (SignInPage covers them).
    NAV_AND_FOOTER_LINKS = [
      '#primary-menu-container a[href]',
      '.main_header__links:not(.menu_dropdown) a[href]',
      '.main_footer a[href]',
      '.sub_footer a[href]'
    ].join(', ').freeze
    TRANSCRIPT_LINK = 'a.transcript_item[href]'
    TRANSCRIPT_PATH = %r{\A/transcripts/(?<institution>[^/]+)/(?<collection>[^/]+)/(?<uid>[^/]+)\z}
    # rails-ujs turns these into a non-GET verb, which a read-only run must not send.
    NON_GET_LINK_ATTRIBUTES = %w[data-method data-turbo-method].freeze
    IGNORED_SCHEMES = %w[mailto tel javascript].freeze

    # Status of the page's own navigation. Selenium has no other way to read it:
    # Capybara cannot read `status_code` through a browser, only through rack_test.
    def navigation_status
      status = page.evaluate_script(<<~JS).to_i
        (function() {
          var entry = performance.getEntriesByType('navigation')[0];
          return entry ? entry.responseStatus : 0;
        })()
      JS
      raise "the browser reported no HTTP status for #{page.current_url}" unless status.positive?

      status
    end

    # Same-origin GET links on the current page, deduplicated. Links that need a
    # non-GET verb, a mail client or a phone dialler are dropped: a read-only run
    # cannot follow them.
    def same_origin_links
      links.partition { |url| same_origin?(url) }.first
    end

    # Links to another host. They are reported in the run's markdown report and
    # never visited, because the tool verifies this deployment, not the internet.
    def external_links
      links.reject { |url| same_origin?(url) }
    end

    def record_external_links(urls = external_links)
      RSpec.current_example.metadata[:staging_external_links] = urls
      urls
    end

    # GETs every same-origin navigation and footer link on the current page and
    # reports them all together, so one run shows every broken page instead of
    # stopping at the first. Links to other hosts are recorded for the report.
    def expect_links_to_resolve
      urls = same_origin_links
      record_external_links
      expect(urls).not_to be_empty, 'the page rendered no navigation or footer links'

      problems = urls.flat_map { |url| link_problems(url) }
      expect(problems).to be_empty, "#{problems.size} of #{urls.size} links failed:\n#{problems.join("\n")}"
    end

    # The word that appears in the most rendered lines (and is long enough for the
    # deployment's trigram search to match it): searching for it must return the
    # transcript it came from, whatever language the content happens to be in.
    def broad_search_term(lines, minimum_length: 5)
      words = lines.flat_map { |line| line.to_s.downcase.scan(/[[:alpha:]]+/) }
      words = words.select { |word| word.length >= minimum_length }
      term = words.tally.max_by { |word, count| [count, word.length] }&.first
      raise "the transcript rendered no word of #{minimum_length}+ letters to search for" if term.nil?

      term
    end

    # A public transcript found on the deployment's own home page. Remote runs
    # have no IDs to hand, so the transcript is discovered from the listing.
    def transcript_ref
      @transcript_ref ||= begin
        match = TRANSCRIPT_PATH.match(transcript_href)
        TranscriptRef.new(institution_slug: match[:institution], collection_uid: match[:collection], uid: match[:uid])
      end
    end

    private

    # Everything one GET of a link got wrong, or nothing at all.
    def link_problems(url)
      page.visit(url)
      status = navigation_status
      problems = []
      problems << "GET #{url} answered HTTP #{status}" unless (200..399).cover?(status)
      problems << "GET #{url} rendered no text" if page.text.strip.empty?
      problems
    end

    def transcript_href
      HomePage.new.visit_path
      href = page.all(TRANSCRIPT_LINK, visible: :all).map { |link| link['href'].to_s }
                 .find { |candidate| TRANSCRIPT_PATH.match?(URI.parse(candidate).path) }
      raise "the deployment's home page listed no transcript links (#{TRANSCRIPT_LINK})" if href.nil?

      URI.parse(href).path
    end

    def links
      page.all(NAV_AND_FOOTER_LINKS, visible: :all).filter_map { |link| link_url(link) }.uniq
    end

    # The absolute URL of a link a read-only run may follow, or nil for one it may
    # not.
    def link_url(link)
      return nil unless followable?(link)

      url = URI.join(page.current_url, link['href'].to_s.strip)
      side_effect_get?(url) ? nil : url.to_s
    rescue URI::InvalidURIError
      nil
    end

    # The read-only guard would fail the run after such a GET had already been
    # sent; the walk does not send it at all.
    def side_effect_get?(url)
      ReadOnlyGuard::SIDE_EFFECT_GET_PATHS.any? { |pattern| pattern.match?(url.path.to_s) }
    end

    # Whether a GET of this link is a read-only navigation: not a non-GET verb
    # (rails-ujs), a mail client, a phone dialler or a same-page anchor.
    def followable?(link)
      return false if NON_GET_LINK_ATTRIBUTES.any? { |attribute| link[attribute].present? }

      href = link['href'].to_s.strip
      return false if href.empty? || href.start_with?('#')

      IGNORED_SCHEMES.exclude?(href.split(':').first.to_s.downcase)
    end

    def same_origin?(url)
      uri = URI.parse(url)
      [uri.scheme, uri.host, uri.port] == [target_uri.scheme, target_uri.host, target_uri.port]
    rescue URI::InvalidURIError
      false
    end

    def target_uri
      @target_uri ||= URI.parse(Target.url!)
    end
  end

  module_function

  def skipped?(example) = example.metadata[:staging_skipped] || example.execution_result.status == :pending

  # Screenshot then read-only check, in that order: the screenshot is worth more
  # while the page a failed example left behind is still rendered, and the guard
  # reads (and clears) Chrome's performance log afterwards.
  def record_evidence(example)
    return unless Target.configured?
    return if skipped?(example)

    session = Capybara.current_session
    return unless ReadOnlyGuard.browser_started?(session)

    session.save_screenshot(File.basename(ReportFormatter.screenshot_path(example.full_description)))
    ReadOnlyGuard.check!(session, target: Target.url)
  end

  # Running the whole suite with STAGING_URL set would point Capybara at the
  # deployment for the local feature specs too (they need the in-process app), so
  # that combination is refused with an explanation instead of failing obscurely.
  def assert_staging_only_run!
    return unless Target.configured?

    foreign = RSpec.configuration.files_to_run.reject { |file| staging_spec?(file) }
    return if foreign.empty?

    raise <<~MESSAGE
      STAGING_URL is set, so Capybara drives #{Target.url} instead of the Rails app,
      but this run also loads specs outside spec/staging (#{foreign.first}).
      Run the staging suite on its own: bin/staging-smoke #{Target.url}
    MESSAGE
  end

  def staging_spec?(file) = File.expand_path(file).start_with?(File.expand_path(__dir__))
end

# Certificate errors are *not* ignored: unlike the local driver there is no
# self-signed CDN stub in the way, so a certificate error here is a genuinely
# misconfigured environment and must fail the run. The window is desktop-sized
# for the same reason as the local drivers' (spec/support/capybara.rb).
Capybara.register_driver Staging::STAGING_DRIVER do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: ['headless', 'disable-gpu', 'no-sandbox', 'disable-dev-shm-usage', LocalChrome::WINDOW_SIZE],
    logging_prefs: { browser: 'ALL', performance: 'ALL' }
  )
  # The deployment serves the project content's media from a third-party CDN, and
  # unlike the local drivers there is no stub in the way here. A media request that
  # host never answers holds the load event - and the visit - for Selenium's 300s
  # default. Eager returns control at DOMContentLoaded; every assertion still waits
  # for the element it needs, and the performance log the guard reads is already
  # populated by then.
  options.page_load_strategy = :eager
  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 clear_session_storage: true,
                                 clear_local_storage: true,
                                 options: options
end

if Staging::Target.configured?
  # No in-process application: every visit goes to the deployment over the wire.
  Capybara.app = nil
  Capybara.app_host = Staging::Target.url
  Capybara.run_server = false
  Capybara.default_driver = Staging::STAGING_DRIVER
  Capybara.javascript_driver = Staging::STAGING_DRIVER
  Capybara.save_path = Staging::ReportFormatter::SCREENSHOT_ROOT
end

RSpec.configure do |config|
  # The staging journeys are `RSpec.feature` blocks, which Capybara's own
  # integration covers; the explicit includes keep `page`, `visit` and the Capybara
  # matchers available to a plain `RSpec.describe ..., :staging` group too.
  config.include Capybara::DSL, :staging
  config.include Capybara::RSpecMatchers, :staging
  config.include Staging::Remote, :staging

  config.before(:suite) do
    Staging.assert_staging_only_run!
  end

  # A skipped journey never opened a browser: it is flagged here so evidence
  # capture stays away from it (an example's pending status is only settled after
  # these hooks have run).
  config.before(:each, :staging) do |example|
    next if Staging::Target.configured?

    example.metadata[:staging_skipped] = true
    skip('STAGING_URL not set: nothing to verify (bin/staging-smoke <url>)')
  end

  config.before(:each, :requires_credentials) do |example|
    next if Staging::Target.credentials?

    example.metadata[:staging_skipped] = true
    skip('STAGING_EMAIL/STAGING_PASSWORD not set')
  end

  config.before(:each, :requires_admin_credentials) do |example|
    next if Staging::Target.admin_credentials?

    example.metadata[:staging_skipped] = true
    skip('STAGING_ADMIN_EMAIL/STAGING_ADMIN_PASSWORD not set')
  end

  config.after(:each, :staging) do |example|
    Staging.record_evidence(example)
  end
end
