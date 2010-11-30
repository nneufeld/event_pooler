desc "Notify all attendees of any event (that is within the next 24 hours) that the said event is within the next 24 hours"
task :notification_event_oneday_reminder => :environment do
	tstart = Time.new
	tstart = tstart + 86400
	tend = tstart + 86400
	
	@events = Event.find(:all, :conditions => ['starts_at >= ? AND ends_at <= ?',
		tstart.strftime('%Y-%m-%d 00:00:00'), tend.strftime('%Y-%m-%d 00:00:00')])
	
	@events.each do |event|
		puts "Sending one day reminders to all attendees of #{event.name}"
		event.attendees.each do |attendee|
			if attendee.accepts_event_notifications
				email = EventMailer.oneday_reminder(event, attendee).deliver
				puts "Sending notification to: #{attendee.email} ... #{email}"
			end
		end
	end
end