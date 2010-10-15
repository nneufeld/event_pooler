class CreateSharables < ActiveRecord::Migration
  def self.up
    create_table :sharables do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
  end

  def self.down
    drop_table :sharables
  end
end
