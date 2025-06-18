require "csv"
require "fileutils"

namespace :speakers do
  # Usage rake speakers:load['oral-history','speakers_seeds.csv']
  desc "Load transcripts by project key and csv file"
  task :load, [:project_key, :filename] => :environment do |_task, args|
    # Validate project
    project_path = Rails.root.join("project", args[:project_key])
    if !File.directory?(project_path)
      puts "No project directory found for: #{args[:project_key]}"
      exit
    end

    # Validate file
    file_path = Rails.root.join("project", args[:project_key], "data", args[:filename])
    if !File.exist? file_path
      puts "No transcript file found: #{file_path}"
      exit
    end

    # Get speakers from file
    speakers = get_speakers_from_file(file_path)
    puts "Retrieved #{speakers.length} rows from file"

    # Write to database
    speakers.each do |attributes|
      speaker = Speaker.find_or_create_by(name: attributes[:name])

      transcript = Transcript.find_by uid: attributes[:transcript_uid]

      if transcript
        ts = TranscriptSpeaker.find_or_initialize_by(speaker_id: speaker.id, transcript_id: transcript.id)
        ts.update(project_uid: args[:project_key], collection_id: transcript.collection_id)
      end
    end

    puts "Wrote #{speakers.length} transcript speakers to database"
  end

  def get_speakers_from_file(file_path)
    csv_body = File.read(file_path)
    csv = CSV.new(csv_body, headers: true, header_converters: :symbol, converters: [:all])
    csv.to_a.map { |row| row.to_hash }
  end
end
