class AddRemoteDataToEvent < ActiveRecord::Migration
  def self.up
      add_column :events, :remote_id, :string
      add_column :events, :remote_source, :string
  end

  def self.down
      remove_column :events, :remote_id
      remove_column :events, :remote_source
  end
end