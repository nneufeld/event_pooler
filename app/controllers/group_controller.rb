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
		
		call_rake :notification_group_similar_sharingprefs, {:group_id => @group.id}
		
        redirect_to group_invite_path(params[:event_id], @group.id) and return if @group.invite_only?
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
		call_rake :notification_group_similar_sharingprefs, {:group_id => @group.id}
        @group.save
        redirect_to group_path(params[:event_id], @group.id) and return
      end
    end
  end
  
  def show_group
    @group = Group.find(params[:id], :include => [:comments, :memberships, :users])
    if @group.invite_only? && !@group.users.include?(current_user) && !current_user.group_invitations.map{|i| i.group}.include?(@group)
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
    #TODO: if they don't belong to the event, add them
    group = Group.find(params[:id])
    invite = GroupInvitation.find_by_group_id_and_email(group.id, current_user.email)
    if group.invite_only?
      if invite.nil?
        flash[:message] = 'You must be invited to this group in order to join.'
        redirect_to event_path(group.event_id) and return
      end
    end
    unless group.users.include?(current_user)
      unless group.event.attendees.include?(current_user)
        # if the user is joining a group, let's add them to the event right away
        event = group.event
        event_group = event.event_group
        membership = Membership.new(:user => current_user, :group => event_group, :approved => true)
        membership.save
        call_rake :notification_event_new_registrant, {:event_id => event.id, :registrant_id => current_user.id}
      end
      membership = Membership.new(:user => current_user, :group => group, :approved => false)
      membership.approved = true if group.public? || (!invite.nil? && invite.from = group.administrator)
      membership.save
      unless invite.nil?
        invite.destroy
        puts 'Just destroyed the invitations'
      end
      if group.private?
        # send the admin an approval email
        GroupMailer.approve_membership(group, current_user).deliver
        flash[:message] = 'Your membership request has been sent to the group administrator.'
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
	
    call_rake :notification_event_user_sharepref_update, {
      :group_id => params[:id],
      :user_id => current_user.id
    }
  end

  def invite
    if request.post?
      addresses = params[:email_addresses].split(',')
      addresses.each do |address|
        invite = GroupInvitation.new(:group_id => params[:id], :from => current_user, :email => address.strip, :message => params[:message])
        invite.generate_token
        invite.save
        GroupMailer.group_invitation(invite).deliver
      end

      flash[:message] = 'Invitations have been successfully sent.'
      redirect_to group_path(params[:event_id], params[:id]) and return
    end
    @group = Group.find(params[:id])
  end

  def accept_invitation
    invite = GroupInvitation.find_by_token(params[:token])
    unless invite.nil?
      # when the user tries to join an invite-only group, their email needs to have an invitation
      # this code lets them sign up with a different email than their invitation
      invite.email = current_user.email
      invite.save
      redirect_to join_group_path(invite.group.event_id, invite.group_id) and return
    end
    flash[:message] = 'Invalid token'
    redirect_to root_path
  end

  def ignore_invitation
    invite = GroupInvitation.find_by_token(params[:token])
    unless invite.nil?
      invite.destroy
      redirect_to request.referer and return
    end
    flash[:message] = 'Invalid token'
    redirect_to root_path
  end

  def leave
    group = Group.find(params[:id])
    unless current_user.nil?
      if current_user == group.administrator
        flash[:message] = 'As the group administrator, you cannot remove yourself from this group'
        redirect_to group_path(params[:id]) and return
      end
      group.memberships.for_user(current_user).each do |membership|
        membership.destroy
      end
      flash[:message] = 'You have been removed from the group.'
    end
    redirect_to event_path(params[:event_id]) and return
  end

  def belongs_to_group
    @group = Group.find(params[:id])
    unless @group.users.include?(current_user)
      flash[:message] = 'You are not a member of this group'
      redirect_to event_path(@group.event.id) and return
    end
  end

end