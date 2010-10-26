require 'digest/sha1'

# user authentication code based on http://www.aidanf.net/rails_user_authentication_tutorial

class User < ActiveRecord::Base
  has_many :memberships
  has_many :comments
  has_many :notifications
  has_many :group_invitations

  validates_length_of :password, :within => 6..40, :if => :validate_password?
  validates_presence_of :name, :email, :salt
  validates_presence_of :password, :password_confirmation, :if => :validate_password?
  validates_uniqueness_of :email
  validates_confirmation_of :password, :if => :validate_password?
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"

  attr_protected :id, :salt

  attr_accessor :password, :password_confirmation, :validate_password

	def validate_password?
		return true unless !self.new_record? && self.password.blank?
	end

  def password=(pass)
    @password=pass
    unless password.blank?
		  self.salt = User.random_string(10) if !self.salt?
		  self.hashed_password = User.encrypt(@password, self.salt)
    end
  end

  def self.authenticate(email, password)
    user = self.where({:email => email}).first
    return nil if user.nil?
    return user if User.encrypt(password, user.salt) == user.hashed_password
    return nil
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
end
