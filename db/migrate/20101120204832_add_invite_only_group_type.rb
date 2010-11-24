class AddInviteOnlyGroupType < ActiveRecord::Migration
  def self.up
    change_table :group_types do |t|
      t.string :description
    end

    gt = GroupType.new
    gt.name = 'Invite-Only'
    gt.slug = 'invite-only'
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
