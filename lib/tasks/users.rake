# frozen_string_literal: true

namespace :users do
  # Usage:
  #     rake users:recalculate[2]
  #     rake users:recalculate
  desc "Recalculate a user's contributions, or all users' contributions"
  task :recalculate, [:user_id] => :environment do |_task, args|
    args.with_defaults user_id: false

    users = []

    users = if args[:user_id].present?
              User.where(id: args[:user_id])

            else
              User.all
            end

    users.each(&:recalculate)

    puts "Updated #{users.length} users"
  end
end
