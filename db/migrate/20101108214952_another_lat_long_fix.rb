class AnotherLatLongFix < ActiveRecord::Migration
  # lat longs need another decimal place
  def self.up
    change_table :events do |t|
      t.remove :latitude
      t.remove :longitude
      t.decimal :latitude, :precision => 8, :scale => 5
      t.decimal :longitude, :precision => 8, :scale => 5
    end

    change_table :users do |t|
      t.remove :latitude
      t.remove :longitude
      t.decimal :latitude, :precision => 8, :scale => 5
      t.decimal :longitude, :precision => 8, :scale => 5
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :latitude
      t.remove :longitude
      t.decimal :latitude, :precision => 7, :scale => 5
      t.decimal :longitude, :precision => 7, :scale => 5
    end

    change_table :users do |t|
      t.remove :latitude
      t.remove :longitude
      t.decimal :latitude, :precision => 7, :scale => 5
      t.decimal :longitude, :precision => 7, :scale => 5
    end
  end
end
