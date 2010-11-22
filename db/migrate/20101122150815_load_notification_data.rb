class LoadNotificationData < ActiveRecord::Migration
  def self.up
	# initial notification types
	# general notifications (emails, etc)
	notification_general = NotificationType.new
	notification_general.slug = 'general'
	notification_general.form_description = 'Yes, I want to receive general notifications'
	notification_general.save
	
	# event notifications (reminders, updates, etc)
	notification_event = NotificationType.new
	notification_event.slug = 'event'
	notification_event.form_description = 'Yes, I want to receive event updates and reminders'
	notification_event.save
	
	# sharing preferences (notification when userh as similar sharing preferences)
	notification_sharepref = NotificationType.new
	notification_sharepref.slug = 'share_pref'
	notification_sharepref.form_description = 'Yes, I want to learn about new users who have similar sharing preferences'
	notification_sharepref.save
	
  end

  def self.down
	Notification.delete_all
  end
end
