class AddGroupTypeDescriptions < ActiveRecord::Migration
  def self.up
    gt = GroupType.find_by_slug('invite-only')
    gt.description = 'Group can only be seen and joined by those invited by the creator.'
    gt.save

    gt = GroupType.find_by_slug('event')
    gt.description = "Default group for an event's main page."
    gt.save

    gt = GroupType.find_by_slug('public')
    gt.description = "Group is fully visible and can be joined by anyone."
    gt.save

    gt = GroupType.find_by_slug('private')
    gt.description = "Group can only be viewed and joined by users approved by the creator."
    gt.save
  end

  def self.down
    gt = GroupType.find_by_slug('invite-only')
    gt.description = nil
    gt.save

    gt = GroupType.find_by_slug('event')
    gt.description = nil
    gt.save

    gt = GroupType.find_by_slug('public')
    gt.description = nil
    gt.save

    gt = GroupType.find_by_slug('private')
    gt.description = nil
    gt.save
  end
end
