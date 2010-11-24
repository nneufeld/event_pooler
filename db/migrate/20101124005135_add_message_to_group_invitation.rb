class AddMessageToGroupInvitation < ActiveRecord::Migration
  def self.up
    change_table :group_invitations do |t|
      t.text :message
    end
  end

  def self.down
    change_table :group_invitations do |t|
      t.remove :message
    end
  end
end
