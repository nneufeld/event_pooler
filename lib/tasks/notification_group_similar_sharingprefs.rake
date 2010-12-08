desc "Notification to let other's know that a group has similar sharing prefs as them who are attending the same event"
task :notification_group_similar_sharingprefs => :environment do
	@group = Group.find(ENV["GROUP_ID"])
	unless @group.nil?
    unless @group.invite_only?
      @group.event.event_group.memberships.each do |member|
        if member.user.accepts_sharepref_notifications && member.user != @group.administrator
          check = false
          @group.sharables.each do |share|
            if member.has_sharable(share)
              check = true
            end
          end

          if check
            email = GroupMailer.group_sharingpref_similar(@group, member.user).deliver
            puts "Sending notification to: #{member.user.email} ... #{email}"
          end

        end
      end
    end
	
		# @group.event.event_group.members.attendees.each do |attendee|
		#	membership = attendee.
		#	if attendee.user.accepts_sharepref_notifications
				# email = GroupMailer.group_sharingpref_similar(group, attendee)
		#		puts "Sending notification to: #{attendee.email} ... "
		#	end
		# end
	else
		puts "Unable to find group for specified ID"
	end
end