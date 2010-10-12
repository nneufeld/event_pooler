class User < ActiveRecord::Base
  has_many :shares
  has_many :comments
  has_many :notifications
  has_many :group_invitations
end
