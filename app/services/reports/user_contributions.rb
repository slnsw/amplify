# frozen_string_literal: true
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
        'User ID', 'Name', 'Edits', 'Lines', 'Transcripts',
        'Collections', 'Institutions', 'Time Spent (s)'
      ]
    end

    def base_filters
      conditions = []
      binds = {}
      
      if params[:start_date].present?
        conditions << "transcript_edits.updated_at >= :start_date"
        binds[:start_date] = params[:start_date]
      end
      
      if params[:end_date].present?
        conditions << "transcript_edits.updated_at <= :end_date"
        binds[:end_date] = params[:end_date]
      end
      
      if params[:collection_id].present?
        conditions << "collections.id = :collection_id"
        binds[:collection_id] = params[:collection_id].to_i
      end
      
      if params[:institution_id].present?
        conditions << "institutions.id = :institution_id"
        binds[:institution_id] = params[:institution_id].to_i
      end
      
      {
        where_clause: conditions.any? ? "WHERE #{conditions.join(' AND ')}" : '',
        binds: binds
      }
    end

    def fetch_rows
      filters = base_filters
      ActiveRecord::Base.connection.exec_query(
        main_query(limit: @per_page, offset: offset, where_clause: filters[:where_clause]),
        'SQL',
        filters[:binds].map { |k, v| [k, v] }
      ).to_a
    end

    def fetch_all
      filters = base_filters
      ActiveRecord::Base.connection.exec_query(
        main_query(where_clause: filters[:where_clause]),
        'SQL',
        filters[:binds].map { |k, v| [k, v] }
      ).to_a
    end

    def total_count
      filters = base_filters
      sql = <<-SQL
        SELECT COUNT(DISTINCT users.id) AS count
        FROM users
        LEFT JOIN transcript_edits ON transcript_edits.user_id = users.id
        LEFT JOIN transcript_lines ON transcript_lines.id = transcript_edits.transcript_line_id
        LEFT JOIN transcripts ON transcripts.id = transcript_lines.transcript_id
        LEFT JOIN collections ON collections.id = transcripts.collection_id
        LEFT JOIN institutions ON institutions.id = collections.institution_id
        #{filters[:where_clause]}
      SQL

      ActiveRecord::Base.connection.exec_query(
        sql,
        'SQL',
        filters[:binds].map { |k, v| [k, v] }
      ).first['count'].to_i
    end

    def main_query(limit: nil, offset: nil, where_clause: '')
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
        #{where_clause}
        GROUP BY users.id
        ORDER BY edit_count DESC
        #{'LIMIT %d OFFSET %d' % [limit, offset] if limit && offset}
      SQL
    end

    def offset
      (@page - 1) * @per_page
    end
  end
end
