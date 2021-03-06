require 'digest/sha1'

# user authentication code based on http://www.aidanf.net/rails_user_authentication_tutorial

class User < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_many :comments
  has_many :user_reviews, :dependent => :destroy
  has_attached_file :avatar, 
                    :styles => { :medium => "100x100>",
                                 :thumb => "40x40>" }

	  has_many :notifications, :dependent => :destroy
	  has_many :notification_types, :through => :notifications


  validates_length_of :password, :within => 6..40, :if => :validate_password?
  validates_presence_of :name, :email, :salt
  validates_presence_of :password, :password_confirmation, :if => :validate_password?
  validates_uniqueness_of :email
  validates_confirmation_of :password, :if => :validate_password?
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"

  attr_protected :id, :salt

  attr_accessor :password, :password_confirmation, :validate_password

  scope :sharing_with_group, lambda{|sharables, group|
    select('DISTINCT users.*').joins('INNER JOIN memberships m ON users.id = m.user_id INNER JOIN memberships_sharables ms ON ms.membership_id = m.id').where('m.group_id = ? AND ms.sharable_id IN (?)', group.id, sharables.map{|s| s.id})
  }
  
  def accepts_sharepref_notifications
	notiftype = NotificationType.where({:slug => 'share_pref'}).first
	return true unless Notification.where({:notification_type_id => notiftype.id, :user_id => self.id}).first.nil?
	return false
  end
  
  def accepts_event_notifications
	notiftype = NotificationType.where({:slug => 'event'}).first
	return true unless Notification.where({:notification_type_id => notiftype.id, :user_id => self.id}).first.nil?
	return false
  end
  
  def accepts_general_notifications
	notiftype = NotificationType.where({:slug => 'general'}).first
	return true unless Notification.where({:notification_type_id => notiftype.id, :user_id => self.id}).first.nil?
	return false
  end

  def password=(pass)
    @password=pass
    unless password.blank?
		  self.salt = User.random_string(10) if !self.salt?
		  self.hashed_password = User.encrypt(@password, self.salt)
    end
  end

  def self.authenticate(email, password)
    user = User.where(['email = ? AND token IS NULL', email]).first
    return nil if user.nil?
    return user if User.encrypt(password, user.salt) == user.hashed_password
    return nil
  end

  def generate_token
    begin
      t = User.random_string(20)
    end while !User.find_by_token(t).nil?
    self.token = t
  end

  def group_invitations
    return GroupInvitation.find_all_by_email(self.email)
  end

  protected

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest(password+salt)
  end

  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def validate_password?
		return true unless !self.new_record? && self.password.blank?
	end
end
