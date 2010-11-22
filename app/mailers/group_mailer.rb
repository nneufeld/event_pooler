class GroupMailer < ActionMailer::Base
  default :from => "EventPooler<donotreply@eventpooler.com>"

  def approve_membership(group, user)
    @group = group
    @user = user
    @host = '0.0.0.0:3000' #TODO: host should be moved to some config file

    mail(:to => @group.administrator.email,
        :subject => "Membership Request For The Group '#{@group.name}'"
    )
  end

  def membership_approved(group, user)
    @group = group
    @user = user
    @host = '0.0.0.0:3000' #TODO: host should be moved to some config file

    mail(:to => @user.email,
        :subject => "Membership Approved For The Group '#{@group.name}'"
    )
  end

  def membership_rejected(group, user)
    @group = group
    @user = user
    @host = '0.0.0.0:3000' #TODO: host should be moved to some config file

    mail(:to => @user.email,
        :subject => "Membership Rejected For The Group '#{@group.name}'"
    )
  end
end
