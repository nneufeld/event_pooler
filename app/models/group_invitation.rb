# before_filter - user has to belong to the group to go there.

class GroupInvitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
end
