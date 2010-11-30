class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_and_belongs_to_many :sharables

  scope :for_user, lambda {|user| where(:user_id => user.id)}
  scope :for_group, lambda{|group| where(:group_id => group.id)}
  
  scope :approved, where({:approved => true})
  
  def has_similar_sharables(membership)
	raise "Argument one must be of type Membership - #{membership.class}" unless membership.kind_of? Membership
	
	self.sharables.each do |sharable|
		if true == membership.has_sharable(sharable)
			return true
		end
	end
	
	return false
  end
  
  def has_sharable(sharable)
	raise "Argument one must be of type Sharable - #{sharable.class}" unless sharable.kind_of? Sharable

	sharables.each do |check|
		if check.id == sharable.id
			return true
		end
	end
	
	return false
  end
  
end
