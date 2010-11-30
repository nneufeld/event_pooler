class CreateNotificationTypes < ActiveRecord::Migration
  def self.up
    create_table :notification_types do |t|
      t.string :slug
	  t.string :form_description

      t.timestamps
    end
  end

  def self.down
    drop_table :notification_types
  end
end
