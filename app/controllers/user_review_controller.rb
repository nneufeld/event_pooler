class UserReviewController < ApplicationController
  before_filter :login_required

  def new
    @review = UserReview.new(params[:user_review])
    @review.user_id = params[:id]
    @review.reviewer_id = current_user.id
    @review.save
    redirect_to profile_url(@review.user_id)
  end

end