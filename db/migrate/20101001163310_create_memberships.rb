class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :group_id
      t.boolean :approved

      t.timestamps
    end

    # set up the intermediate table for has_and_belongs_to_many association with sharables
    create_table :memberships_sharables, :id => false do |t|
      t.integer :membership_id
      t.integer :sharable_id
    end
  end

  def self.down
    drop_table :memberships
    drop_table :memberships_sharables
  end
end
