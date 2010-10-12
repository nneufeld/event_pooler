class Group < ActiveRecord::Base
  belongs_to :event
  has_many :comments
  has_many :shares
  has_many :notifications
  has_many :group_invitations
end
