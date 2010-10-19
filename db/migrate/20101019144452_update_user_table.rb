class UpdateUserTable < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.rename :password, :hashed_password
      t.string :salt
    end
  end

  def self.down
  end
end
