class AddGroupTypeToGroup < ActiveRecord::Migration
  def self.up
    # for some reason I forgot to a group type id to this table
    change_table :groups do |t|
      t.integer :group_type_id
    end
  end

  def self.down
    change_table :groups do |t|
      t.remove :group_type_id
    end
  end
end
