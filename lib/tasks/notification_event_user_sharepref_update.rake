desc "Notification to let other's know that a user has updated his or her sharing preferences that are similar to theres"
task :notification_event_user_sharepref_update => :environment do
	# event = Event.find(ENV["EVENT_ID"]);
	@group = Group.find(ENV["GROUP_ID"]);
	@user = User.find(ENV["USER_ID"]);
	@user_membership = @user.memberships.for_group(@group).first
	
	unless @user_membership.nil?
		@group.memberships.each do |gmember|
			unless @user.id == gmember.user.id
				# test if user wants to receive notifications
				if gmember.user.accepts_sharepref_notifications && gmember.has_similar_sharables(@user_membership)
					email = GroupMailer.membership_sharingpref_similar(@user, gmember.user, @group).deliver
					puts "Sending notification to: #{gmember.user.email} ... #{email}"
				end
			end
		end
	else
		puts "Unable to lookup user memberships for group."
	end
	
end