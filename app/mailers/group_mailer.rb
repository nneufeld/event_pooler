class GroupMailer < ActionMailer::Base
  default :from => "EventPooler<donotreply@eventpooler.com>"

  def approve_membership(group, user)
    @group = group
    @user = user

    mail(:to => @group.administrator.email,
        :subject => "Membership Request For The Group '#{@group.name}'"
    )
  end

  def membership_approved(group, user)
    @group = group
    @user = user

    mail(:to => @user.email,
        :subject => "Membership Approved For The Group '#{@group.name}'"
    )
  end

  def membership_rejected(group, user)
    @group = group
    @user = user

    mail(:to => @user.email,
        :subject => "Membership Rejected For The Group '#{@group.name}'"
    )
  end

  def group_invitation(invitation)
    @invitation = invitation
    @group = invitation.group
    @user = User.find_by_email(@invitation.email)

    mail(:to => @invitation.email,
        :subject => "#{@invitation.from.name} Has Invited You To A Group On EventPooler"
    )
  end
  
  def membership_sharingpref_similar(user, ruser, group)
	@user = user
	@ruser = ruser
	@group = group
  
	mail(:to => ruser.email, :subject => "#{@ruser.name} has updated their sharing preferences")
  end
  
  def group_sharingpref_similar(group, user)
	@user = user
	@group = group
	@event = group.event
	
	mail(:to => user.email, :subject => "#{group.event.name} has a new group with similar sharing preferences")
  end
end
