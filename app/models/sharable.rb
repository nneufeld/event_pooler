class Sharable < ActiveRecord::Base
  has_many :shares
end
