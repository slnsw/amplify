namespace :report do

  # Usage:
  #     rake report:users
  #     rake report:users[1]
  desc "Report on user activities"
  task :users, [:user_id] => :environment do |task, args|
    args.with_defaults user_id: false

    users = []
    report_params = {}

    if !args[:user_id].blank?
      users = User.where(id: args[:user_id])
    else
      users = User.all
    end

    report = users.map { |user|
      user.getReport(report_params)
    }

    puts report.to_json
  end

end
