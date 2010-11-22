class AddInviteOnlyGroupType < ActiveRecord::Migration
  def self.up
    change_table :group_types do |t|
      t.string :description
    end

    gt = GroupType.new
    gt.name = 'Invite-Only'
    gt.slug = 'invite-only'
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
    change_table :group_types do |t|
      t.remove :description
    end

    gt = GroupType.find_by_slug('invite-only')
    gt.destroy
  end
end
