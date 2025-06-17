# frozen_string_literal: true

class RemoveVendorIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :collections, name: 'index_collections_on_vendor_id_and_vendor_identifier'
    remove_index :transcripts, name: 'index_transcripts_on_vendor_id_and_vendor_identifier'
  end
end
