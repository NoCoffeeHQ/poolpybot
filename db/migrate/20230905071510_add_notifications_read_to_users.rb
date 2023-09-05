class AddNotificationsReadToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :notifications_read_at, :datetime
  end
end
