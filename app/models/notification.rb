class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification_type
  belongs_to :group
  
  scope :for_user, lambda {|user| where(:user_id => user.id)}
end
