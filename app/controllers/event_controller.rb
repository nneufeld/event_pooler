class EventController < ApplicationController

def event_find
  @events = Event.event_find(params[:q])
end

end