class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :location
      t.datetime :starts_at
      t.datetime :ends_at
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
