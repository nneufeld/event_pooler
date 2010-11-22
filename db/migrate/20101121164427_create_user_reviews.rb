class CreateUserReviews < ActiveRecord::Migration
  def self.up
    create_table :user_reviews do |t|
      t.integer :user_id
      t.integer :reviewer_id
      t.integer :rank
      t.string :review
      t.integer :event_id
    end
  end

  def self.down
    drop_table :user_reviews
  end
end
