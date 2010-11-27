class RenameEventUserToAdministrator < ActiveRecord::Migration
  def self.up
    rename_column :events, :user_id, :administrator_id
  end

  def self.down
    rename_column :events, :administrator_id, :user_id
  end
end
