class EventController < ApplicationController

def search
  @events = Event.search(params[:q])
end

end