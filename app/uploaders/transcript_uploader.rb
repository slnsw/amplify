class TranscriptUploader < CarrierWave::Uploader::Base
  include S3Identifier

  storage :file

  # The audio files are converted to transcript.srt files by the VoiceBase vendor
  # these files are stored within the project directory. There are existing
  # rake tasks that reference these files and support the content review process.
  def store_dir
    "#{Rails.root}/app/files/uploads/#{ENV['PROJECT_ID']}/"
  end
end
