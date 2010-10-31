class EventController < ApplicationController

  before_filter :login_required, :only=>[:attend]
  
def event_find
  @events = Event.event_find(params[:q], params[:loc])
end

def event_page
    @event = Event.find_by_id(params[:id])
    unless current_user.nil?
      @my_sharables = @event.event_group.memberships.for_user(current_user).first.sharables
    end
end

def attend
  event = Event.find(params[:id])
  event_group = event.event_group
  membership = Membership.new
  membership.user = current_user
  membership.group = event_group
  membership.approved = true
  membership.save
  redirect_to event_path(event.id)
end

def update_sharables
  event = Event.find(params[:id])
  event_group = event.event_group
  membership = event_group.memberships.for_user(current_user).first
  membership.sharables.clear
  Sharable.all.each do |sharable|
    if params[sharable.slug]
      membership.sharables << sharable
    end
  end
  @my_sharables = membership.sharables
end

end