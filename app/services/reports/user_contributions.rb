# app/services/reports/user_activity.rb
require 'csv'

module Reports
  class UserContributions
    attr_reader :params

    def initialize(params)
      @params = params
      @per_page = (params[:per_page] || 50).to_i
      @page     = (params[:page] || 1).to_i
    end

    def results
      @results ||= WillPaginate::Collection.create(@page, @per_page, total_count) do |pager|
        pager.replace(fetch_rows)
      end
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << headers
        fetch_all.each do |row|
          csv << [
            row['user_id'],
            row['name'],
            row['line_count'],
            row['edit_count'],
            row['transcript_count'],
            row['collection_count'],
            row['institution_count'],
            row['time_spent']
          ]

        end
      end
    end

    private

    def headers
      [
        "User ID", "Name", "Edits", "Lines", "Transcripts",
        "Collections", "Institutions", "Time Spent (s)"
      ]
    end

    def base_filters
      filters = []
      filters << "transcript_edits.updated_at >= #{quoted(:start_date)}" if params[:start_date].present?
      filters << "transcript_edits.updated_at <= #{quoted(:end_date)}" if params[:end_date].present?
      filters << "collections.id = #{params[:collection_id]}" if params[:collection_id].present?
      filters << "institutions.id = #{params[:institution_id]}" if params[:institution_id].present?
      filters.any? ? "WHERE #{filters.join(' AND ')}" : ""
    end

    def fetch_rows
      ActiveRecord::Base.connection.exec_query(main_query(limit: @per_page, offset: offset)).to_a
    end

    def fetch_all
      ActiveRecord::Base.connection.exec_query(main_query).to_a
    end

    def total_count
      sql = <<-SQL
        SELECT COUNT(DISTINCT users.id) AS count
        FROM users
        LEFT JOIN transcript_edits ON transcript_edits.user_id = users.id
        LEFT JOIN transcript_lines ON transcript_lines.id = transcript_edits.transcript_line_id
        LEFT JOIN transcripts ON transcripts.id = transcript_lines.transcript_id
        LEFT JOIN collections ON collections.id = transcripts.collection_id
        LEFT JOIN institutions ON institutions.id = collections.institution_id
        #{base_filters}
      SQL

      ActiveRecord::Base.connection.exec_query(sql).first['count'].to_i
    end

    def main_query(limit: nil, offset: nil)
      seconds_per_line = Transcript.seconds_per_line

      <<-SQL
        SELECT
          users.id AS user_id,
          users.name AS name,
          COUNT(DISTINCT transcript_edits.id) AS edit_count,
          COUNT(DISTINCT transcript_edits.transcript_line_id) AS line_count,
          COUNT(DISTINCT transcript_lines.transcript_id) AS transcript_count,
          COUNT(DISTINCT transcripts.collection_id) AS collection_count,
          COUNT(DISTINCT collections.institution_id) AS institution_count,
          COUNT(transcript_edits.id) * #{seconds_per_line} AS time_spent
        FROM users
        LEFT JOIN transcript_edits ON transcript_edits.user_id = users.id
        LEFT JOIN transcript_lines ON transcript_lines.id = transcript_edits.transcript_line_id
        LEFT JOIN transcripts ON transcripts.id = transcript_lines.transcript_id
        LEFT JOIN collections ON collections.id = transcripts.collection_id
        LEFT JOIN institutions ON institutions.id = collections.institution_id
        #{base_filters}
        GROUP BY users.id
        ORDER BY edit_count DESC
        #{'LIMIT %d OFFSET %d' % [limit, offset] if limit && offset}
      SQL
    end

    def offset
      (@page - 1) * @per_page
    end

    def quoted(key)
      ActiveRecord::Base.connection.quote(params[key])
    end
  end
end
