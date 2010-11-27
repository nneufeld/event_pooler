class UserMailer < ActionMailer::Base
  default :from => "EventPooler<donotreply@eventpooler.com>"

  def welcome_email(user)
    @user = user
    mail(:to => user.email,
         :subject => "Welcome to EventPooler")
  end

  def forgot_password(user)
    @user = user
    mail(:to => user.email,
         :subject => "Reset Your EventPooler Password")
  end
end
