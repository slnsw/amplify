# frozen_string_literal: true

require 'rspec/core/formatters/base_formatter'
require 'time'

module Staging
  # Writes the evidence report for a staging run: a markdown table of every
  # journey with its result, duration and screenshot, followed by the failure
  # messages, every browser console entry (all levels, not only errors) and the
  # external links the run found but did not visit.
  #
  # Registered as `RSpec::Core::Formatters.register self, :example_passed,
  # :example_failed, :example_pending, :dump_summary, :close`; bin/staging-smoke
  # points it at tmp/staging_report/report.md with `--out`, and RSpec hands the
  # formatter that file as its output stream. Screenshot paths live here so the
  # examples that take them and the report that links them cannot drift apart.
  class ReportFormatter < RSpec::Core::Formatters::BaseFormatter
    PASSED = 'PASS'
    FAILED = 'FAIL'
    SKIPPED = 'SKIP'

    REPORT_ROOT = 'tmp/staging_report'
    SCREENSHOT_ROOT = File.join(REPORT_ROOT, 'screenshots').freeze
    SCREENSHOT_LINK_ROOT = 'screenshots'
    NONE = '_None._'
    MESSAGE_LINES = 40

    RSpec::Core::Formatters.register self, :example_passed, :example_failed, :example_pending, :dump_summary, :close

    # A filename-safe, stable name for an example's screenshot. Long descriptions
    # are truncated so the path stays inside the filesystem's limits.
    def self.screenshot_name(description)
      name = description.to_s.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/\A-+|-+\z/, '')[0, 80].to_s
      name.empty? ? 'example' : name
    end

    def self.screenshot_path(description)
      File.join(SCREENSHOT_ROOT, "#{screenshot_name(description)}.png")
    end

    def initialize(output)
      super
      @results = []
      @summary = nil
      @started_at = Time.current
    end

    def example_passed(notification)
      record(notification.example, PASSED)
    end

    def example_failed(notification)
      record(notification.example, FAILED)
    end

    def example_pending(notification)
      record(notification.example, SKIPPED)
    end

    def dump_summary(summary)
      @summary = summary
    end

    def close(_notification)
      output.puts(render)
    end

    private

    def record(example, status)
      @results << { example: example, status: status }
    end

    def render
      [
        header,
        results_table,
        failures_section,
        console_entries_section,
        external_links_section
      ].join("\n")
    end

    def header
      lines = [
        '# Staging verification report',
        '',
        "- **Target:** #{target}",
        "- **Started:** #{@started_at.strftime('%Y-%m-%d %H:%M:%S %Z')}",
        "- **Result:** #{result_counts}"
      ]
      lines << "- **Duration:** #{format('%.1fs', @summary.duration)}" if @summary
      lines.push('', 'Every journey below is a read-only browser session. After each one the read-only',
                 'guard fails the run if the browser sent a non-GET (other than the sign-in POST,',
                 'a CSP report or an analytics beacon) or a GET with side effects (sync, sign-out).', '')
      lines.join("\n")
    end

    def target
      url = ENV['STAGING_URL'].to_s
      url.empty? ? '_STAGING_URL not set_' : url
    end

    def result_counts
      return '_no examples ran_' if @summary.nil?

      counts = "#{@summary.example_count} example(s): #{passed_count} passed, " \
               "#{@summary.failure_count} failed, #{@summary.pending_count} skipped"
      errors = @summary.errors_outside_of_examples_count
      # A suite-level error - a raise in a `before(:suite)`, a failing `after(:suite)`
      # - runs no example, so it never reaches the results table. The header is the
      # only place the report can say the run did not finish cleanly.
      errors.positive? ? "#{counts} — #{errors} error(s) outside examples" : counts
    end

    # SummaryNotification reports counts for everything but the passes.
    def passed_count
      @summary.example_count - @summary.failure_count - @summary.pending_count
    end

    def results_table
      return "_No results._\n" if @results.empty?

      rows = @results.map { |result| table_row(result) }
      [
        '| Journey | Result | Duration | Screenshot |',
        '| --- | --- | --- | --- |',
        *rows,
        ''
      ].join("\n")
    end

    def table_row(result)
      example = result[:example]
      "| #{cell(example.full_description)} | #{result[:status]} | " \
        "#{format('%.2fs', example.execution_result.run_time.to_f)} | #{screenshot_cell(example)} |"
    end

    def screenshot_cell(example)
      path = self.class.screenshot_path(example.full_description)
      return '_none_' unless File.exist?(path)

      name = File.basename(path)
      "[#{name}](#{SCREENSHOT_LINK_ROOT}/#{name})"
    end

    # A pipe inside a description would break the table, and an unescaped
    # backslash would swallow the pipe escape, so escape the backslashes first.
    def cell(text) = text.to_s.gsub('\\') { '\\\\' }.gsub('|') { '\|' }

    def failures_section
      failures = @results.select { |result| result[:status] == FAILED }
      return "## Failures\n\n#{NONE}\n" if failures.empty?

      [
        '## Failures',
        '',
        *failures.flat_map { |result| failure_block(result[:example]) }
      ].join("\n")
    end

    def failure_block(example)
      message = example.execution_result.exception&.message.to_s
      lines = message.lines.first(MESSAGE_LINES).join
      lines += "\n(truncated)\n" if message.lines.size > MESSAGE_LINES

      ["### #{example.full_description}", '', '```', lines.chomp, '```', '']
    end

    # Every level Chrome logged, so a warning that explains a failure is not lost;
    # the JS console hook only *fails* an example on SEVERE entries. A journey whose
    # log could not be read is listed separately: an empty section must not read as
    # evidence that the console was clean.
    def console_entries_section
      entries = @results.filter_map do |result|
        logged = Array(result[:example].metadata[:javascript_console_entries])
        next if logged.empty?

        "- **#{result[:example].full_description}**\n#{logged.map { |entry| "  - #{entry}" }.join("\n")}"
      end

      sections = ['## Browser console entries (all levels)', '', entries.empty? ? NONE : entries.join("\n"), '']
      sections += no_console_evidence_section
      sections.join("\n")
    end

    def no_console_evidence_section
      unavailable = @results.filter_map do |result|
        reason = result[:example].metadata[:javascript_console_unavailable]
        next unless reason

        "- **#{result[:example].full_description}** — console log unavailable (#{reason})"
      end
      return [] if unavailable.empty?

      ['', '### Journeys with no console evidence', '', unavailable.join("\n"), '']
    end

    def external_links_section
      links = @results.flat_map { |result| Array(result[:example].metadata[:staging_external_links]) }.uniq.sort
      return "## External links (not visited)\n\n#{NONE}\n" if links.empty?

      ['## External links (not visited)', '', *links.map { |link| "- #{link}" }, ''].join("\n")
    end
  end
end
