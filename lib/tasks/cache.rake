namespace :cache do
  # Usage rake cache:clear
  desc "Clear a cache fragment"
  task clear: :environment do |_task, _args|
    puts "Clearing all cache: #{Rails.cache.clear}"
  end

  # Usage rake cache:clear_fragment['oral-history/transcripts/1/1000/title']
  desc "Clear cache fragment(s)"
  task :clear_fragment, [:keys] => :environment do |_task, args|
    keys = [args[:keys].split(":")].flatten.uniq

    keys.each do |k|
      if Rails.cache.read(k)
        puts "DELETING key #{k}: #{Rails.cache.delete(k)}"

      else
        puts "DOESN'T EXIST: #{k}"
      end
    end
  end

  # Usage rake cache:read['oral-history/transcripts/1/1000/title']
  desc "Read cache fragment(s)"
  task :read, [:keys] => :environment do |_task, args|
    keys = [args[:keys].split(":")].flatten.uniq

    keys.each do |k|
      puts "#{k}: #{Rails.cache.read(k)}"
    end
  end
end
