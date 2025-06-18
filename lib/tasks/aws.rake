namespace :aws do
  # Usage: rake aws:upload_files['nsw-state-library-amplify','ap-southeast-2','slnsw-amplify','collections/rainbow_archives/audio']
  desc "Upload files in the specified directory to AWS S3"
  task :upload_files, [:project_key, :region, :bucket, :key_path] => :environment do |_task, args|
    credentials = Aws::Credentials.new(ENV["AWS_S3_ACCESS_KEY_ID"], ENV["AWS_S3_SECRET_ACCESS_KEY"])
    s3 = Aws::S3::Resource.new(credentials: credentials, region: args[:region])

    files = Dir["#{Rails.root}/public/#{args[:key_path]}/*"]

    files.each do |file|
      key_file = file.split("/").last
      key = [args[:key_path], key_file].join("/")

      obj = s3.bucket(args[:bucket]).object(key)
      obj.upload_file(file, acl: "public-read")
      puts "Uploaded: #{obj.public_url}"
    end
  end
end
