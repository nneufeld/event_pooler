class MainController < ApplicationController
  def index
    @my_events = Event.attended_by(current_user).order(:starts_at) unless current_user.nil?
  end
end