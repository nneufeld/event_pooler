require 'net/https'
require 'net/http'

class UserController < ApplicationController

	before_filter :login_required, :only=>[:myaccount, :delete_account]
	
  def signup
    @user = User.new(params[:user])
    if request.post?
      @user.registered_on = DateTime.now
      if @user.valid?
        @user.generate_token
        location = @user.address + ", " + @user.city + ", " + @user.region
        unless @user.address.blank? && @user.city.blank? && @user.region.blank?
          lat_lng = get_lat_lng(location)
          @user.latitude = lat_lng[:lat]
          @user.longitude = lat_lng[:lng]
        end
        begin
          UserMailer.welcome_email(@user).deliver
          @user.save
          redirect_to :action => "welcome" and return
        rescue
          flash[:message] = 'Error sending email.'
        end
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
			
			@user.notification_types.clear
			NotificationType.all.each do |notiftype|
				if params['notifications'][notiftype.slug]
					@user.notification_types << notiftype
				end
			end
			
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
    #TODO: when delete, fix issue with comments
    current_user.destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  def login
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      unless user.nil?
        return_to = session[:return_to]
        reset_session
        session[:return_to] = return_to
        session[:user_id] = user.id
				current_user.last_login = DateTime.now
				current_user.save
        redirect_to_stored
      else
        flash[:warning] = "Login unsuccessful"
      end
    end
  end
  
  def logout
    session[:user_id] = nil
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
  
  def profile
    @user = User.find(params[:id])

    if request.post?
      message = params[:message]
      EventMailer.contact_user(current_user, @user, message).deliver
      flash[:message] = 'Message was sent to user'
    end
  end


end
