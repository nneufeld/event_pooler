class AddColumnsToGroup < ActiveRecord::Migration
  def self.up
    change_table :groups do |t|
      t.integer :administrator_id
      t.string :city
      t.string :region
      t.decimal :latitude, :precision => 8, :scale => 5
      t.decimal :longitude, :precision => 8, :scale => 5
    end

    create_table :groups_sharables, :id => false do |t|
      t.integer :group_id
      t.integer :sharable_id
    end
  end

  def self.down
    change_table :groups do |t|
      t.remove :administrator_id
      t.remove :city
      t.remove :region
      t.remove :latitude
      t.remove :longitude
    end

    drop_table :groups_sharables
  end
end
