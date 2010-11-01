class UpdateLatLong < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.remove :latitude
      t.remove :longitude
      t.decimal :latitude
      t.decimal :longitude
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :latitude
      t.remove :longitude
      t.integer :latitude
      t.integer :longitude
    end
  end
end
