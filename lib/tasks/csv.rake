# frozen_string_literal: true

namespace :csv do
  # Usage:
  #     rake csv:merge[project/the-moth/data/transcripts_seeds.csv,project/the-moth/data/transcripts_seeds2.csv,uid,project/the-moth/data/transcripts_seeds3.csv]
  desc 'Merges two csv files into one; assumes headers are present'
  task :merge, %i[file_a file_b merge_id file_output] => :environment do |_task, args|
    # build file paths
    file_a_path = Rails.root + args[:file_a].to_s
    file_b_path = Rails.root + args[:file_b].to_s
    file_output_path = Rails.root + args[:file_output].to_s

    # read the files
    data_a = get_from_file(file_a_path)
    data_b = get_from_file(file_b_path)

    puts "Found #{data_a.length} rows in #{file_a_path}"
    puts "Found #{data_b.length} rows in #{file_b_path}"

    # retrieve and merge the headers
    headers = []
    headers.concat data_a.first.keys if data_a.length.positive?
    headers.concat data_b.first.keys if data_b.length.positive?
    headers = headers.uniq

    # merge rows
    merged_data = (data_a + data_b).group_by { |h| h[args[:merge_id].to_sym] }.map { |_k, v| v.inject(:merge) }

    # Write to file
    update_file(file_output_path, merged_data, headers)
    puts "Wrote #{merged_data.length} rows to #{file_output_path}"
  end

  def get_from_file(file_path)
    csv_body = File.read(file_path)
    csv = CSV.new(csv_body, headers: true, header_converters: :symbol, converters: [:all])
    csv.to_a.map(&:to_hash)
  end

  def update_file(file_path, data, headers)
    CSV.open(file_path, 'wb') do |csv|
      csv << data.first.keys # adds the attributes name on the first line
      data.each do |hash|
        values = []
        headers.each do |key|
          values << hash[key]
        end
        csv << values
      end
    end
  end
end
