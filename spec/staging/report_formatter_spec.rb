# frozen_string_literal: true

require_relative 'report_formatter'

RSpec.describe Staging::ReportFormatter do
  describe '#cell' do
    subject(:formatter) { described_class.allocate }

    it 'leaves an ordinary description alone' do
      expect(formatter.send(:cell, 'Transcript editor renders lines')).to eq('Transcript editor renders lines')
    end

    it 'escapes a pipe so it cannot end the table cell' do
      expect(formatter.send(:cell, 'sign_in | sign_out')).to eq('sign_in \| sign_out')
    end

    it 'doubles a backslash so it cannot swallow the pipe escape' do
      expect(formatter.send(:cell, 'a\\b')).to eq('a\\\\b')
    end

    it 'escapes both when a backslash precedes a pipe' do
      expect(formatter.send(:cell, 'a\\|b')).to eq('a\\\\\|b')
    end
  end

  describe 'the console appendix' do
    subject(:formatter) { described_class.new(StringIO.new) }

    # The formatter only reads `full_description` and the two metadata keys, so a
    # Struct stands in for a real example.
    def example_named(metadata)
      Struct.new(:full_description, :metadata).new('Transcript editor renders lines', metadata)
    end

    def section_for(metadata)
      formatter.send(:record, example_named(metadata), :passed)
      formatter.send(:console_entries_section)
    end

    it 'says none when the browser logged nothing it kept' do
      expect(section_for({})).to include(described_class::NONE)
    end

    # An empty section would read as evidence that the console was clean.
    it 'names a journey whose console log could not be read', :aggregate_failures do
      section = section_for(javascript_console_unavailable: 'the driver has no logs API')

      expect(section).to include('Journeys with no console evidence')
      expect(section).to include('Transcript editor renders lines', 'the driver has no logs API')
    end

    it 'leaves the section out when every journey had its console read' do
      expect(section_for({})).not_to include('Journeys with no console evidence')
    end
  end

  describe 'the run summary' do
    subject(:formatter) { described_class.new(StringIO.new) }

    def summary_with(errors_outside_examples:, failures: 0)
      Struct.new(:example_count, :failure_count, :pending_count, :duration, :errors_outside_of_examples_count)
            .new(3, failures, 1, 1.5, errors_outside_examples)
    end

    it 'counts the examples that ran' do
      formatter.dump_summary(summary_with(errors_outside_examples: 0))

      expect(formatter.send(:render)).to include('3 example(s): 2 passed, 0 failed, 1 skipped')
    end

    # A suite-level error runs no example, so it cannot appear in the results
    # table: without this the report of a run that died in `before(:suite)` reads
    # as a clean run of fewer examples.
    it 'says when errors happened outside the examples' do
      formatter.dump_summary(summary_with(errors_outside_examples: 2))

      expect(formatter.send(:render)).to include('2 error(s) outside examples')
    end
  end
end
