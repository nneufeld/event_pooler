class AddLocationToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.decimal :latitude
      t.decimal :longitude
      t.string  :address
      t.string  :city
      t.string  :region
      t.string  :code
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :latitude
      t.remove :longitude
      t.remove :address
      t.remove :city
      t.remove :region
      t.remove :code
    end
  end
end
