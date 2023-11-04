# frozen_string_literal: true

namespace :poolpybot do
  namespace :reports do
    desc 'Send a summary of all what happened for the past day'
    task daily: :environment do
      yesterday = Time.zone.today - 1.day
      User.report_daily.find_each do |user|
        notifications = user.company.notifications.optimized.ordered.created_on(yesterday)

        next if notifications.empty?

        UserMailer.daily_activity_digest(user, notifications, yesterday).deliver_now

        puts "✉️  daily report sent at #{user.email}!"
      end
    end

    desc 'Send a summary of all what happened for the past week'
    task weekly: :environment do
      last_week = Time.zone.today - 1.week
      begin_date = last_week.beginning_of_week
      end_date = last_week.end_of_week
      User.report_weekly.find_each do |user|
        notifications = user.company.notifications.optimized.ordered.created_between(begin_date, end_date)

        next if notifications.empty?

        UserMailer.weekly_activity_digest(user, notifications, begin_date, end_date).deliver_now

        puts "✉️  weekly report sent at #{user.email}!"
      end
    end
  end
end
