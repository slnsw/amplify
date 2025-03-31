class AddProjectToTranscript < ActiveRecord::Migration[7.0]
  def change
    add_column :transcripts, :project_uid, :string, :null => false, :default => ""
    add_column :collections, :project_uid, :string, :null => false, :default => ""
    remove_column :projects, :active

    add_index :transcripts, :project_uid
    add_index :collections, :project_uid
  end
end
