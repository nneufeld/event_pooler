class AddLatLongToEvent < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.integer :latitude
      t.integer :longitude
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :latitude
      t.remove :longitude
    end
  end
end
