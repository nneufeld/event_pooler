class EventController < ApplicationController

def event_find
  @events = Event.event_find(params[:q], params[:loc])
end

def event_page
  if(params[:source] == "native")
    @event = Event.find_by_id(params[:id], params[:loc])
  end
end

end