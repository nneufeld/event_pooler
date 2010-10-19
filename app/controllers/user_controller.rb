class UserController < ActionController::Base
  def signup
    @user = User.new(params[:user])
    if request.post?
      @user.registered_on = DateTime.now
      if @user.save
        session[:user] = User.authenticate(@user.email, @user.password)
        redirect_to :action => "welcome" and return
      end
    end
  end

  def welcome
    
  end
end