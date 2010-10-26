class UserController < ApplicationController

	before_filter :login_required, :only=>[:welcome, :myaccount, :delete_account]
	
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

	def myaccount
    @user = current_user
		if request.post?
			email_changed = params[:user][:email] != @user.email
			@user.update_attributes(params[:user])
			if @user.valid?
				@user.avatar = params[:avatar] unless params[:avatar].blank?
				@user.save
				flash[:message] = "Account successfully updated. "
				flash[:message] += "You will need to use your new email address as your login id in the future. " if email_changed
			end
		end
  end
  
  def delete_account
    current_user.destroy
    session[:user] = nil
    redirect_to root_path
  end

  def login
    if request.post?
      if session[:user] = User.authenticate(params[:email], params[:password])
				current_user.last_login = DateTime.now
				current_user.save
        redirect_to_stored
      else
        flash[:warning] = "Login unsuccessful"
      end
    end
  end
  
  def logout
    session[:user] = nil
    flash[:message] = 'Logged out'
    redirect_to root_path
  end
end
