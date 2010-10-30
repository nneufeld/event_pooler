class EventMailer < ActionMailer::Base
  default :from => "EventPooler<donotreply@eventpooler.com>"

  def contact_user(event, from_user, to_user, message)
    @event = event
    @from_user = from_user
    @to_user = to_user
    @message = message

    mail(:to => to_user.email,
        :from => "EventPooler<message@eventpooler.com>",
        :reply_to => from_user.email,
        :subject => "#{@from_user.name} sent you a message on EventPooler")
  end
end
