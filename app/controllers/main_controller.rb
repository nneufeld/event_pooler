class MainController < ApplicationController
  def index
    @my_events = Event.attended_by(current_user).order(:starts_at) unless current_user.nil?

    @popular_events = Event.where("starts_at >= ?", Time.now.to_i).closest_to_user
    @popular_events[0...100].sort_by{ |event| event.attendees.count }
    @popular_events = @popular_events[0...10]

    if(current_user)
      @recent_activity = current_user.groups.collect{|group| group.comments }.flatten
      @recent_activity.sort_by{| comment | comment.created_at }
      @recent_activity = @recent_activity[0...10]

      @my_groups = current_user.groups
    end

  end
end