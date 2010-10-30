class EventController < ApplicationController

def event_find
  @events = Event.event_find(params[:q], params[:loc])
end

def event_page
    @event = Event.find_by_id(params[:id])
end

end