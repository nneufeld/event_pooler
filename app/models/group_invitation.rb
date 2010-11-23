# before_filter - user has to belong to the group to go there.

class GroupInvitation < ActiveRecord::Base
  belongs_to :group
  belongs_to :from, :class_name => 'User'

  def generate_token
    begin
      t = GroupInvitation.random_string(20)
    end while !GroupInvitation.find_by_token(t).nil?
    self.token = t
  end

  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
end
