class NotificationsController < ApplicationController
  def deliver_general
    call_rake :send_general_notifications
    redirect_to root_url
  endah
  
  def deliver_events
    redirect_to root_url
  end
  
  def deliver_sharepref
    redirect_to root_url
  end
end
