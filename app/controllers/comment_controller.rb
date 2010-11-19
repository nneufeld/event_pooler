class CommentController < ApplicationController
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
end