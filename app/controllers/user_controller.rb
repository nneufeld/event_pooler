class UserController < ApplicationController
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

  def login
    if request.post?
      if session[:user] = User.authenticate(params[:email], params[:password])
        flash[:message]  = "Login successful"
        redirect_to '/'
      else
        flash[:warning] = "Login unsuccessful"
      end
    end
  end
  
  def logout
    session[:user] = nil
    flash[:message] = 'Logged out'
    redirect_to '/'
  end
end