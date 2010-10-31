class AddCreatedByToEvent < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.integer :user_id
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :user_id
    end
  end
end
