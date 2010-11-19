class CommentController < ApplicationController
  before_filter :login_required
  before_filter :belongs_to_group, :only => [:create]
  
  def reply
    parent_comment = Comment.find(params[:comment_id])
    @comment = Comment.new
    @comment.parent_id = params[:comment_id]
    @group = parent_comment.group
  end

  def new
    @comment = Comment.new(params[:comment])
    @comment.group_id = params[:group_id]
    @comment.user_id = current_user.id
    @comment.save
  end

  def belongs_to_group
    @group = Group.find(params[:group_id])
    unless @group.users.include?(current_user)
      flash[:message] = 'You are not a member of this group'
      redirect_to event_path(@group.event.id) and return
    end
  end
end