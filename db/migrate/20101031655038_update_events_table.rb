class UpdateEventsTable < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.string :address
      t.string :city
      t.string :region
      t.string :code
      t.string :phone
      t.string :email
      t.string :url
      t.remove :location
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :address
      t.remove :city
      t.remove :region
      t.remove :code
      t.remove :phone
      t.remove :email
      t.remove :url
      t.string :location
    end
  end
end
