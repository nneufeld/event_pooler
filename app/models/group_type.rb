class GroupType < ActiveRecord::Base
  has_many :groups

  scope :user_selectable, where(['slug != ?', 'event'])
end
