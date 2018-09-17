# check and download the voicebase trasncripts
set :output, "log/cron_log.log"
env :PATH, ENV['PATH']

every 5.minutes do
  rake "voice_base:import_transcripts_from_api"
end

