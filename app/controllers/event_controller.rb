require 'will_paginate'
class EventController < ApplicationController

  before_filter :login_required, :except=>[:event_find, :event_page]
  
  def event_find
    location = params[:loc]
    if location.blank?
      unless current_user.nil? || current_user.latitude.blank?
        location = "#{current_user.latitude}, #{current_user.longitude}"
      end
    end
    @events = Event.event_find(params[:q], location)
  end

  def event_page
    @event = Event.find_by_id(params[:id])
    @group = @event.event_group
    @groups = @event.groups.user_groups
    @attendees = @event.attendees
    unless current_user.nil?
      membership = @event.event_group.memberships.for_user(current_user).first
      @my_sharables = membership.sharables unless membership.nil?
    end

    if !current_user.nil? && @event.event_group.users.include?(current_user)
      @comment = Comment.new(params[:comment])
      @comment.group_id = @event.event_group.id
      @comment.user_id = current_user.id


      if !Comment.find_by_user_id_and_message_and_group_id(current_user.id, @comment.message, @comment.group_id).nil?
        @comment = Comment.new
      end

      if request.post? && !@comment.message.blank?
        @comment.save
        @comment = Comment.new
      end
    end
  end

  def attend
    event = Event.find(params[:id])
    event_group = event.event_group
    unless event_group.users.include?(current_user)
      membership = Membership.new(:user => current_user, :group => event_group, :approved => true)
      membership.save
    end
    redirect_to event_path(event.id)
  end

  def contact_user
    @event = Event.find(params[:id])
    @to_user = User.find(params[:user_id])

    if request.post?
      message = params[:message]
      EventMailer.contact_user(@event, current_user, @to_user, message).deliver
      flash[:message] = 'Message was sent to user'
      redirect_to event_path(@event.id)
    end
  end

  def cancel_attendance
    event = Event.find(params[:id])
    event_group = event.event_group

    private_groups = Group.find_all_by_event_id(event.id)

    #cancel private group memberships
    private_groups.each do |group|
      group.memberships.for_user(current_user).each do |membership|
        membership.destroy
      end
    end

    event_group.memberships.for_user(current_user).each do |membership|
      membership.destroy
    end
    flash[:message] = 'Attendance has been removed'
    redirect_to event_path(event.id)
  end

  def filter_attendees
    sharables_filter = []
    Sharable.all.each do |sharable|
      if params[sharable.slug]
        sharables_filter << sharable
      end
    end

    location_filter = []
    if params['city']
      location_filter = params['city'].split(", ")
    end


    p location_filter[0]
    p location_filter[1]

    @event = Event.find(params[:id])


    @attendees = @event.attendees

    if !sharables_filter.empty?
      @attendees = User.sharing_with_group(sharables_filter, @event.event_group)
    end
    if !location_filter.empty?
      @attendees = @attendees.find_all_by_city_and_region(location_filter[0], location_filter[1])
    end

  end

  def filter_groups
    sharables_filter = []
    Sharable.all.each do |sharable|
      if params[sharable.slug]
        sharables_filter << sharable
      end
    end

    location_filter = []
    if params['city']
      location_filter = params['city'].split(", ")
    end


    p location_filter[0]
    p location_filter[1]

    @event = Event.find(params[:id])


    @groups = @event.groups.user_groups

    if !sharables_filter.empty?
      @groups = @groups.sharing(sharables_filter)
    end
    if !location_filter.empty?
      @groups = @groups.where(['city = ? AND region = ?', location_filter[0], location_filter[1]])
    end

  end

  def new
      location = params[:address] + ", " + params[:city] + ", " + params[:region]
      unless params[:address].blank? && params[:city].blank? && params[:region].blank?
        latlong_uri = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.escape(location)}&sensor=false")
        latlong = Net::HTTP.get_response(latlong_uri)

        location = JSON.parse(latlong.body)

        lng = location['results'].first['geometry']['location']['lng'] rescue ""
        lat = location['results'].first['geometry']['location']['lat'] rescue ""
      end

    event = Event.create(
      :name=> params[:name],
      :description => params[:description],
      :starts_at => Chronic.parse(params['start_time']),
      :ends_at => Chronic.parse(params['end_time']),
      :remote_id => nil,
      :remote_source => "native",
      :user_id => current_user,
      :address => params[:address],
      :city => params[:city],
      :region => params[:region],
      :code => params[:code],
      :phone => params[:phone],
      :email => params[:email],
      :url => params[:url],
      :latitude => lat,
      :longitude => lng
    )

    redirect_to event_path(:id => event.id)

  end

  def create
  end

end