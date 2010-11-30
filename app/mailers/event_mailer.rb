class EventMailer < ActionMailer::Base
  default :from => "EventPooler<donotreply@eventpooler.com>"

  def contact_user(from_user, to_user, message)
    @from_user = from_user
    @to_user = to_user
    @message = message

    mail(:to => to_user.email,
        :from => "EventPooler<message@eventpooler.com>",
        :reply_to => from_user.email,
        :subject => "#{@from_user.name} sent you a message on EventPooler")
  end
  
  def oneday_reminder(event, user)
	@event = event
	@user = user
	
	mail(:to => user.email, :subject => "Reminder: Less then 24 hours until #{event.name}")
  end
  
  def new_registrant(event, registrant)
	@event = event
	@registrant = registrant
	
	mail(:to => event.administrator.email, :subject => "#{registrant.name} is now attending #{event.name}")
  end
  
  def event_updated(event, user)
	@event = event
	@user = user
	
	mail(:to => user.email, :subject => "The event details of #{event.name} have been updated")
  end
end
