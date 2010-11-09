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

  def get_lat_lng(search_string)
    latlong_uri = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.escape(search_string)}&sensor=false")
    latlong = Net::HTTP.get_response(latlong_uri)

    location = JSON.parse(latlong.body)

    lng = location['results'].first['geometry']['location']['lng'] rescue ""
    lat = location['results'].first['geometry']['location']['lat'] rescue ""

    return {:lat => lat, :lng => lng}
  end
  helper_method :get_lat_long
  
end
