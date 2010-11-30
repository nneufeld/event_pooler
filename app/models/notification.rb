class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :notification_type
  
  scope :for_user, lambda {|user| where(:user_id => user.id)}
end
