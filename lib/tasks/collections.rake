# frozen_string_literal: true

require 'csv'
require 'fileutils'

namespace :collections do
  # Usage rake collections:load['oral-history','collections_seeds.csv']
  desc 'Load collections by project key and csv file'
  task :load, %i[project_key filename] => :environment do |_task, args|
    # Validate project
    project_path = Rails.root.join('project', args[:project_key], '/')
    unless File.directory?(project_path)
      puts "No project directory found for: #{args[:project_key]}"
      exit
    end

    # Validate file
    file_path = Rails.root.join('project', args[:project_key], 'data', args[:filename])
    unless File.exist? file_path
      puts "No collection file found: #{file_path}"
      exit
    end

    # Get collections to upload
    collections = get_collections_from_file(file_path)
    puts "Retrieved #{collections.length} from file"

    # Write to database
    collections.each do |attributes|
      attributes[:vendor] = Vendor.find_by(uid: attributes[:vendor]) if attributes.key?(:vendor)
      attributes.delete(:vendor) if attributes[:vendor].blank?
      attributes.delete(:vendor_identifier) if attributes[:vendor_identifier].blank?
      attributes[:project_uid] = args[:project_key]
      # puts attributes
      collection = Collection.find_or_initialize_by(uid: attributes[:uid])
      collection.update(attributes)
    end

    puts "Wrote #{collections.length} collections to database"
  end

  # Usage rake collections:update_file['oral-history','collections_seeds.csv']
  desc 'Update a csv file based on data in database'
  task :update_file, %i[project_key filename] => :environment do |_task, args|
    # Validate project
    project_path = Rails.root.join('project', args[:project_key], '/')
    unless File.directory?(project_path)
      puts "No project directory found for: #{args[:project_key]}"
      exit
    end

    # Validate file
    file_path = Rails.root.join('project', args[:project_key], 'data', args[:filename])
    unless File.exist? file_path
      puts "No collection file found: #{file_path}"
      exit
    end

    # Get collections from file
    collections_from_file = get_collections_from_file(file_path)
    collections_from_file.each_with_index do |attributes, i|
      collection = Collection.find_by uid: attributes[:uid]

      # If collection found in DB, update appropriate fields
      collections_from_file[i][:vendor_identifier] = collection[:vendor_identifier] if collection
    end

    # Update the file
    update_collections_to_file(file_path, collections_from_file)
    puts "Updated #{collections_from_file.length} collections in file"
  end

  def get_collections_from_file(file_path)
    collections = []

    csv_body = File.read(file_path)
    csv = CSV.new(csv_body, headers: true, header_converters: :symbol, converters: [:all])
    csv.to_a.map(&:to_hash)
  end

  def update_collections_to_file(file_path, collections)
    CSV.open(file_path, 'wb') do |csv|
      csv << collections.first.keys # adds the attributes name on the first line
      collections.each do |hash|
        csv << hash.values
      end
    end
  end
end
