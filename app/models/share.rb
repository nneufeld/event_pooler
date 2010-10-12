class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_one :sharables
end
