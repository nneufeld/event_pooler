class EventController < ApplicationController

def search
  @events = Event.search(params[:query])
end

end