class Comment < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  acts_as_tree

  scope :original, where({:parent_id => nil})
end
