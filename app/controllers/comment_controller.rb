class CommentController < ApplicationController
def comment_reply
  @comment = Comment.new
  respond_to do |format|
        format.html { render 'shared/_comment_form' }
        format.js
  end
end

def comment_reply
  p params
  p "HELLO THERE!"
end

end