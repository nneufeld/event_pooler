require 'net/https'
require 'net/http'

class UserController < ApplicationController

	before_filter :login_required, :only=>[:myaccount, :delete_account]
	
  def signup
    @user = User.new(params[:user])
    if request.post?
      @user.registered_on = DateTime.now
      if @user.save
        @user.generate_token
        location = @user.address + ", " + @user.city + ", " + @user.region
        unless @user.address.blank? && @user.city.blank? && @user.region.blank?
          lat_lng = get_lat_lng(location)
          @user.latitude = lat_lng[:lat]
          @user.longitude = lat_lng[:lng]
        end
        @user.save
        UserMailer.welcome_email(@user).deliver
        redirect_to :action => "welcome" and return
      end
    end
  end

  def welcome
    
  end

  def confirm
    @user = User.where({:token => params[:token]}).first
    unless @user.nil?
      @user.token = nil
      @user.save
    end
  end

	def myaccount
    @user = current_user
		if request.post?
			email_changed = params[:user][:email] != @user.email
			@user.update_attributes(params[:user])
			if @user.valid?
        location = @user.address + ", " + @user.city + ", " + @user.region
        unless @user.address.blank? && @user.city.blank? && @user.region.blank?
          lat_lng = get_lat_lng(location)
          @user.latitude = lat_lng[:lat]
          @user.longitude = lat_lng[:lng]
        end
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

  def forgot_password
    if request.post?
      @user = User.where({:email => params[:email]}).first
      if @user.nil?
        flash[:message] = 'No user with this email address could be found.'
      else
        @user.generate_token
        @user.save
        UserMailer.forgot_password(@user).deliver
        flash[:message] = 'A reset password link has been sent to your email address'
      end
    end
  end

  def reset_password
    @user = User.where({:token => params[:token]}).first
    @password_reset = false
    if request.post?
      @user.update_attributes(params[:user])
      if @user.save
        @user.token = nil
        @user.save
        @password_reset = true
      end
    end
  end
end
