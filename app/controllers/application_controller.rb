class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    session[:user]
  end
  helper_method :current_user
  
  def login_required
  	if session[:user]
      return true
    end
    session[:return_to] = request.request_uri
    redirect_to login_path and return false
  end
  helper_method :login_required
  
  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to return_to
    else
      redirect_to root_path
    end
  end
  helper_method :redirect_to_stored
  
end
