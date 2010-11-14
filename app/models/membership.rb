class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_and_belongs_to_many :sharables

  scope :for_user, lambda {|user| where(:user_id => user.id)}
  scope :approved, where({:approved => true})
end
