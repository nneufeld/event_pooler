#TODO: add beforefilter to make sure the user belongs to the group
class GroupController < ApplicationController
  before_filter :login_required
  
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
    @comment = Comment.new(params[:comment])
    @comment.group_id = params[:id]
    @comment.user_id = current_user.id
    if !Comment.find_by_user_id_and_message_and_group_id(current_user.id, @comment.message, @comment.group_id).nil?
      @comment = Comment.new
    end
    if request.post? && !@comment.message.blank?
      @comment.save
      @comment = Comment.new
    end
    @group = Group.find(params[:id], :include => [:comments, :memberships, :users])
  end

  #TODO: make this approval based
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
      GroupMailer.membership_approved(group, user)
      flash[:message] = 'User has successfully been added to the group'
    else
      flash[:message] = "Only the group administrator can approve a user's membership"
    end
    redirect_to group_path(group.event.id, group.id) and return
  end

end