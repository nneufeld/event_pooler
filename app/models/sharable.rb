class Sharable < ActiveRecord::Base
  has_and_belongs_to_many :memberships
  has_and_belongs_to_many :groups
end
