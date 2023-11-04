class AddNotificationPreferencesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :notification_on_collecting, :boolean, default: true
    add_column :users, :report_frequency, :integer, default: 0
  end
end
