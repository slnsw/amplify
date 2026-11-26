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
end
