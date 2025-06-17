# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SitemapJob, type: :job do
  before do
    stub_const('SitemapGenerator::Sitemap', Class.new do
      class << self
        attr_accessor :default_host, :added_paths

        def create(&block)
          @added_paths = []
          @add_block = block
          instance_eval(&block)
        end

        def add(path, options = {})
          @added_paths ||= []
          @added_paths << [path, options]
        end
      end
    end)
  end

  let(:institution) { create(:institution, hidden: false, slug: 'inst') }
  let(:collection) { create(:collection, institution: institution) }
  let(:transcript) { create(:transcript, collection: collection) }

  before do
    allow(transcript).to receive(:published?).and_return(true)
    allow(transcript).to receive_message_chain(:decorate, :path).and_return("/transcripts/#{transcript.id}")

    allow(collection).to receive(:published?).and_return(true)
    allow(collection).to receive_message_chain(:decorate, :path).and_return("/collections/#{collection.id}")

    allow(institution).to receive(:published?).and_return(true)
    allow(institution).to receive_message_chain(:decorate, :path).and_return("/institutions/#{institution.slug}")

    allow(Transcript).to receive_message_chain(:joins, :where, :find_each).and_yield(transcript)
    allow(Collection).to receive_message_chain(:joins, :where, :published, :find_each).and_yield(collection)
    allow(Institution).to receive_message_chain(:published, :slugged, :find_each).and_yield(institution)
  end

  it 'adds static and dynamic paths to the sitemap' do
    described_class.new.perform

    expect(SitemapGenerator::Sitemap.added_paths).to include(
      ['/search', { priority: 0.75 }],
      ['/collections', { priority: 0.75 }],
      ['/page/about', { priority: 0.3 }],
      ['/page/faq', { priority: 0.3 }],
      ['/page/tutorial', { priority: 0.3 }],
      ["/transcripts/#{transcript.id}", {}],
      ["/collections/#{collection.id}", {}],
      ["/institutions/#{institution.slug}", {}]
    )
  end
end
