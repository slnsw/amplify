# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Seed User Roles
users_roles = [
  { name: 'guest',             hiearchy: 0,    description: 'Unregistered user' },
  { name: 'user',              hiearchy: 10,   description: 'Registered user' },
  { name: 'moderator',         hiearchy: 50,   description: 'Moderator can review edits' },
  { name: 'content_editor',    hiearchy: 80,   description: 'Content editor can edit content' },
  { name: 'admin',             hiearchy: 100,  description: 'Administrator has all privileges' }
]
users_roles.each do |attributes|
  user_role = UserRole.find_or_initialize_by(name: attributes[:name])
  user_role.update(attributes)
end

# Seed Vendors
vendors = [
  { uid: 'pop_up_archive', name: 'Pop Up Archive', description: 'Pop Up Archive makes sound searchable using cutting edge speech-to-text technology', url: 'https://popuparchive.com/' },
  { uid: 'webvtt', name: 'WebVTT', description: 'WebVTT (Web Video Text Tracks) is a W3C standard for displaying timed text in connection with HTML5.', url: 'https://w3c.github.io/webvtt/' }
]
vendors.each do |attributes|
  vendor = Vendor.find_or_initialize_by(uid: attributes[:uid])
  vendor.update(attributes)
end

# Seed Transcript Statuses
transcript_statuses = [
  { name: 'initialized',            progress: 0,    description: 'Transcript initialized' },
  { name: 'audio_uploaded',         progress: 10,   description: 'Audio has been uploaded' },
  { name: 'transcript_processing',  progress: 20,   description: 'Transcript is being processed' },
  { name: 'transcript_downloaded',  progress: 30,   description: 'Transcript has been downloaded' },
  { name: 'transcript_editing',     progress: 40,   description: 'Transcript is being edited' },
  { name: 'transcript_reviewing',   progress: 50,   description: 'Transcript is being reviewed' },
  { name: 'transcript_complete',    progress: 100,  description: 'Transcript has been completed' },
  { name: 'transcript_problematic', progress: 150,  description: 'Transcript has been completed but may contain errors' },
  { name: 'transcript_archived',    progress: 200,  description: 'Transcript has been archived' }
]
transcript_statuses.each do |attributes|
  status = TranscriptStatus.find_or_initialize_by(name: attributes[:name])
  status.update(attributes)
end

# Seed Transcript Statuses
transcript_line_statuses = [
  { name: 'initialized', progress: 0,    description: 'Line contains unedited computer-generated text. Please edit if incorrect!' },
  { name: 'editing',     progress: 25,   description: 'Line has been edited by others. Please edit if incorrect!' },
  { name: 'reviewing',   progress: 50,   description: 'Line is being reviewed and is no longer editable. Click \'Verify\' to review.' },
  { name: 'completed',   progress: 100,  description: 'Line has been completed and is no longer editable' },
  { name: 'flagged',     progress: 150,  description: 'Line has been marked as incorrect or problematic' },
  { name: 'archived',    progress: 200,  description: 'Line has been archived' }
]
transcript_line_statuses.each do |attributes|
  status = TranscriptLineStatus.find_or_initialize_by(name: attributes[:name])
  status.update(attributes)
end

# Seed Flag Types
flag_types = [
  { name: 'misspellings', label: 'Contains misspellings', category: 'error', description: 'Line contains text that is incorrect or misspelled' },
  { name: 'repeated', label: 'Contains repeated word(s)', category: 'error', description: 'Line contains text that is repeated on the same, previous, or next line' },
  { name: 'missing', label: 'Missing word(s)', category: 'error', description: 'Line is missing text that was spoken in the audio' },
  { name: 'misc_error', label: 'Other', category: 'error', description: 'Any other type of error' }
]
flag_types.each do |attributes|
  type = FlagType.find_or_initialize_by(name: attributes[:name])
  type.update(attributes)
end
