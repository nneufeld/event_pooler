class Group < ActiveRecord::Base
  belongs_to :event
  has_many :comments
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  has_many :notifications
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
    unless user.nil?
      latitude = user.latitude
      longitude = user.longitude
      if latitude.nil? || longitude.nil?
        ip_addr = ENV['REMOTE_ADDR']
        geo = Geokit::Geocoders::IpGeocoder.geocode(ip_addr)
        latitude = geo.lat
        longitude = geo.lng
      end
      unless latitude.nil? || longitude.nil?
        select('DISTINCT groups.*').geo_scope(:origin => [user.latitude, user.longitude]).order('distance')
      end
    end
  }
  

  scope :sharing, lambda {|sharables|
    select('DISTINCT groups.*').joins('INNER JOIN groups_sharables gs ON gs.group_id = groups.id').where(['gs.sharable_id IN (?)', sharables.map{|s| s.id}])
  }

  scope :event_groups, lambda {
    event_type = GroupType.where({:slug => 'event'}).first
    where ({:group_type_id => event_type.id})
  }

  scope :for_user, lambda {|user|
    joins(:memberships).where(['memberships.user_id = ?', user.nil? ? 0 : user.id])
  }

  scope :visible, lambda {
    invite_only_type = GroupType.find_by_slug('invite-only')
    where(['group_type_id != ?', invite_only_type.id])
  }

  def public?
    return self.group_type.slug == 'public'
  end

  def private?
    return self.group_type.slug == 'private'
  end

  def invite_only?
    return self.group_type.slug == 'invite-only'
  end

  def event_type?
    return self.group_type.slug == 'event'
  end

end
