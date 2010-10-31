class Group < ActiveRecord::Base
  belongs_to :event
  has_many :comments
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :notifications
  has_many :group_invitations
  belongs_to :group_type
end
