require 'will_paginate'
require 'icalendar'

class EventController < ApplicationController

  before_filter :login_required, :except=>[:event_find, :event_page]
  
  def event_find
    location = params[:loc]
    if location.blank?
      unless current_user.nil? || current_user.latitude.blank?
        location = "#{current_user.latitude}, #{current_user.longitude}"
      end
    end
    @events = Event.event_find(params[:q], location).sort_by{|event| event.starts_at}.paginate(:page => params[:page], :per_page => 10)
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
      unless current_user == event.administrator
        call_rake :notification_event_new_registrant, {:event_id => event.id, :registrant_id => current_user.id}
      end
    end
    redirect_to event_path(event.id)
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

  def create
    @event = Event.new(params[:event])
    if request.post?
      @event.starts_at += 5.hours unless @event.starts_at.nil?
      @event.ends_at += 5.hours unless @event.ends_at.nil?
      @event.remote_id = nil
      @event.remote_source = "native"
      @event.administrator = current_user

      location = "#{@event.address}, #{@event.city}, #{@event.region}"
      unless location == ", , "
        lat_long = get_lat_lng(location)
        @event.latitude = lat_long[:lat]
        @event.longitude = lat_long[:lng]
      end

      if @event.save

        call_rake "ts:index"

        redirect_to attend_event_path(:id => @event.id) and return
      end
    end

    render 'update'
  end

  def update
    @event = Event.find(params[:id])

    unless @event.administrator == current_user
      flash[:message] = "You don't have access to update this event"
      redirect_to event_path(params[:id]) and return
    end

    if request.post?
      @event.update_attributes(params[:event])
      @event.starts_at += 5.hours unless @event.starts_at.nil?
      @event.ends_at += 5.hours unless @event.ends_at.nil?

      location = "#{@event.address}, #{@event.city}, #{@event.region}"
      unless location == ", , "
        lat_long = get_lat_lng(location)
        @event.latitude = lat_long[:lat]
        @event.longitude = lat_long[:lng]
      end

      @event.save

	  call_rake :notification_event_details_updated, {:event_id => @event.id}
      call_rake "ts:index"

      redirect_to event_path(:id => @event.id) and return
    end
  end

  def export
    @event = Event.find(params[:id])
    @calendar = Icalendar::Calendar.new
    event = Icalendar::Event.new
    event.start = Time.at(@event.starts_at.to_i).strftime("%Y%m%dT%H%M%S")
    event.end = Time.at(@event.ends_at.to_i).strftime("%Y%m%dT%H%M%S") unless @event.ends_at.nil?
    event.summary = @event.name
    event.description = @event.description
    event.location = @event.full_address
    event.url = event_url(@event.id)
    @calendar.add event
    @calendar.publish
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    render :text => @calendar.to_ical
  end

end