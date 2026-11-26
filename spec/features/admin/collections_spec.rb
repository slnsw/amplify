# frozen_string_literal: true

require 'rails_helper'

# /admin/cms lists every collection grouped by institution and is where an
# admin creates one (app/views/admin/cms/collections/_form.html.erb) or renames
# it. Both mutations are proved by the list that renders them.
RSpec.feature 'CMS collections' do
  let(:world) { build_content_world }
  let(:collections) { AdminCmsCollectionsPage.new }
  let(:image) { Rails.root.join('spec/fixtures/4k_example_image.jpg') }

  describe 'as an admin', :js do
    before do
      world
      sign_in_as(:admin)
      collections.visit_index
    end

    scenario 'lists every collection under its institution', :aggregate_failures do
      expect(collections.titles).to include(world.collection.title)
      expect(page).to have_text(world.institution.name)
    end

    scenario 'creates a collection with an image the edit form shows after a reload', :aggregate_failures do
      create_collection(image: image)
      expect(collections.titles).to include('New collection')
      page.refresh
      collections.edit('New collection')
      expect(collections.image_preview?).to be(true)
    end

    scenario 'persists a retitled collection so the list still shows it after a reload', :aggregate_failures do
      collections.edit(world.collection.title).retitle(to: 'Renamed collection')

      expect(collections.titles).to include('Renamed collection')
      page.refresh
      expect(collections.titles).to include('Renamed collection')
    end
  end

  private

  def create_collection(image: nil)
    collections.create(uid: 'new-collection', title: 'New collection', description: 'Oral histories',
                       institution: world.institution.name, image: image)
  end
end
