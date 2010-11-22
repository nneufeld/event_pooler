class GroupController < ApplicationController
  before_filter :login_required
  before_filter :belongs_to_group, :only => [:update_sharables, :approve_membership]
  
  def create
    @group = Group.new(params[:group])
    if request.post?
      @group.slug = Event.generate_slug(@group.name)
      @group.event_id = params[:event_id]
      @group.sharables.clear
      Sharable.all.each do |sharable|
        if params[sharable.slug]
          @group.sharables << sharable
        end
      end
      if @group.save
        @group.administrator = current_user
        membership = Membership.new(:user => current_user, :group => @group, :approved => true)
        membership.save
        unless @group.city.blank? && @group.region.blank?
          lat_long = get_lat_lng(@group.city + ", " + @group.region)
          @group.latitude = lat_long[:lat]
          @group.longitude = lat_long[:lng]
        end
        @group.save
        redirect_to group_path(params[:event_id], @group.id) and return
      end
    end

    render 'update'
  end

  def update
    @group = Group.find(params[:id])

    unless @group.administrator == current_user
      flash[:message] = "You don't have access to update this group"
      redirect_to group_path(params[:event_id], @group.id) and return
    end

    if request.post?
      @group.update_attributes(params[:group])
      @group.slug = Event.generate_slug(@group.name)
      @group.sharables.clear
      Sharable.all.each do |sharable|
        if params[sharable.slug]
          @group.sharables << sharable
        end
      end
      if @group.valid?
        unless @group.city.blank? && @group.region.blank?
          lat_long = get_lat_lng(@group.city + ", " + @group.region)
          @group.latitude = lat_long[:lat]
          @group.longitude = lat_long[:lng]
        end
        @group.save
        redirect_to group_path(params[:event_id], @group.id) and return
      end
    end
  end
  
  def show_group
    @group = Group.find(params[:id], :include => [:comments, :memberships, :users])
    if @group.invite_only? && !@group.users.include?(current_user)
      flash[:message] = "You do not have access to this group"
      redirect_to event_path(@group.event_id) and return
    end
    unless current_user.nil?
      membership = @group.memberships.for_user(current_user).first
      @my_sharables = membership.sharables unless membership.nil?
    end
    @comment = Comment.new
  end

  def join
    group = Group.find(params[:id])
    unless group.users.include?(current_user)
      membership = Membership.new(:user => current_user, :group => group, :approved => false)
      membership.approved = true if group.public?
      membership.save
      unless group.public?
        # send the admin an approval email
        GroupMailer.approve_membership(group, current_user).deliver
      end
    end
    redirect_to group_path(params[:event_id], group.id)
  end

  def approve_membership
    group = Group.find(params[:id])
    user = User.find(params[:user_id])
    if current_user == group.administrator
      membership = group.memberships.for_user(user).first
      membership.approved = true
      membership.save
      GroupMailer.membership_approved(group, user).deliver
      flash[:message] = 'User has successfully been added to the group'
    else
      flash[:message] = "Only the group administrator can approve a user's membership"
    end
    redirect_to group_path(group.event.id, group.id) and return
  end
  
  def reject_membership
    group = Group.find(params[:id])
    user = User.find(params[:user_id])
    if current_user == group.administrator
      membership = group.memberships.for_user(user).first
      membership.destroy
      GroupMailer.membership_rejected(group, user).deliver
      flash[:message] = 'The membership request has been rejected'
    else
      flash[:message] = "Only the group administrator can reject a user's membership"
    end
    redirect_to group_path(group.event.id, group.id) and return
  end

  def update_sharables
    group = Group.find(params[:id])
    membership = group.memberships.for_user(current_user).first
    membership.sharables.clear
    Sharable.all.each do |sharable|
      if params[sharable.slug]
        membership.sharables << sharable
      end
    end
    @my_sharables = membership.sharables
  end

  def belongs_to_group
    @group = Group.find(params[:id])
    unless @group.users.include?(current_user)
      flash[:message] = 'You are not a member of this group'
      redirect_to event_path(@group.event.id) and return
    end
  end

end