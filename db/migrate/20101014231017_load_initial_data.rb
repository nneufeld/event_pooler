class LoadInitialData < ActiveRecord::Migration
  def self.up
    # create some initial sharables

    travel = Sharable.new
    travel.name = 'Travel'
    travel.slug = 'travel'
    travel.save

    accom = Sharable.new
    accom.name = 'Accommodations'
    accom.slug = 'accommodations'
    accom.save

    # create initial group types

    # every new event will have an "Event" group that anyone can post to
    event_type = GroupType.new
    event_type.name = 'Event'
    event_type.slug = 'event'
    event_type.save

    public_type = GroupType.new
    public_type.name = 'Public'
    public_type.slug = 'public'
    public_type.save

    private_type = GroupType.new
    private_type.name = 'Private'
    private_type.slug = 'private'
    private_type.save
  end

  def self.down
    Sharable.delete_all
    GroupType.delete_all
  end
end
