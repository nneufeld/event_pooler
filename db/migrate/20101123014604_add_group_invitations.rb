class AddGroupInvitations < ActiveRecord::Migration
  def self.up
    create_table :group_invitations do |t|
      t.integer :group_id
      t.integer :from_id
      t.string :email
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :group_invitations
  end
end
