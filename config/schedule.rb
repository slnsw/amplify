# check and download the voicebase trasncripts
set :output, "log/cron_log.log"
env :PATH, ENV['PATH']

every 5.minutes do
  runner "VoiceBaseProcessingJob.perform_now"
end

