class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
	  t.integer :user_id
	  t.integer :notification_type
	  
	  t.integer :group_id # Added because there is a relationship between Notification and Group?
	  
      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
