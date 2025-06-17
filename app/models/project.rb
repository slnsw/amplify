# frozen_string_literal: true

class Project
  # rubocop:disable Naming/MethodName
  def self.getActive(collection_id = nil)
    # NOTE: since this method is used across the code, changing the name to snake case
    #       needs to be done seperatly
    project_file = Rails.root.join('project', ENV['PROJECT_ID'], 'project.json')
    project_data = JSON.parse File.read(project_file)

    project_data['consensus'] = institution_config(collection_id) if collection_id
    {
      uid: ENV['PROJECT_ID'],
      data: project_data
    }
  end
  # rubocop:enable Naming/MethodName

  # rubocop:disable Metrics/LineLength
  def self.institution_config(collection_id)
    collection = Collection.find(collection_id)
    institution = collection.institution
    {
      'maxLineEdits' => (collection.max_line_edits || institution.max_line_edits),
      'minLinesForConsensus' => (collection.min_lines_for_consensus || institution.min_lines_for_consensus),
      'minLinesForConsensusNoEdits' => (collection.min_lines_for_consensus_no_edits || institution.min_lines_for_consensus_no_edits),
      'minPercentConsensus' => (collection.min_percent_consensus || institution.min_percent_consensus),
      'lineDisplayMethod' => institution.line_display_method,
      'superUserHiearchy' => institution.super_user_hiearchy
    }
  end
  # rubocop:enable Metrics/LineLength
end
