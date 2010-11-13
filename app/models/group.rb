class Group < ActiveRecord::Base
  belongs_to :event
  has_many :comments
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :notifications
  has_many :posts
  has_many :group_invitations
  belongs_to :group_type
  belongs_to :administrator, :class_name => 'User'
  has_and_belongs_to_many :sharables

  acts_as_mappable :default_units => :kms,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  validates_presence_of :name

  scope :user_groups, lambda {
    event_type = GroupType.where({:slug => 'event'}).first
    where (['group_type_id != ?', event_type.id])
  }

  scope :closest_to_user, lambda {|user|
    unless user.nil? || user.latitude.nil? || user.longitude.nil?
      geo_scope(:origin => [user.latitude, user.longitude]).order('distance')
    end
  }
end
