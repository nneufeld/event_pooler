#TODO: add beforefilter to make sure the user belongs to the group
class GroupController < ApplicationController
  def show_group
    @comment = Comment.new(params[:comment])
    @comment.group_id = params[:group_id]
    @comment.user_id = current_user.id
    if !Comment.find_by_user_id_and_message_and_group_id(current_user.id, @comment.message, @comment.group_id).nil?
      @comment = Comment.new
    end
    if request.post? && !@comment.message.blank?
      @comment.save
      @comment = Comment.new
    end
    @group = Group.find(params[:group_id], :include => [:comments, :memberships, :users])
  end

  #TODO: make this approval based
  def join
    group = Group.find(params[:group_id], :include => :users)
    unless group.users.include?(current_user)
            membership = Membership.new(:user => current_user, :group => group, :approved => true)
      membership.save
    end
    redirect_to group_path(params[:id], group.id)
  end

end