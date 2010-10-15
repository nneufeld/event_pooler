class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_and_belongs_to_many :sharables
end
