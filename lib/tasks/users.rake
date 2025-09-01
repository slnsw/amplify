namespace :users do

  # Usage:
  #     rake users:recalculate[2]
  #     rake users:recalculate
  desc "Recalculate a user's contributions, or all users' contributions"
  task :recalculate, [:user_id] => :environment do |task, args|
    args.with_defaults user_id: false

    users = []

    if !args[:user_id].blank?
      users = User.where(id: args[:user_id])

    else
      users = User.all
    end

    users.each do |user|
      user.recalculate
    end

    puts "Updated #{users.length} users"

  end

end
