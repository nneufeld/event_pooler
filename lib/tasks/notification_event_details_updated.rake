desc "Notify attendees that there is an update to the event information"
task :notification_event_details_updated => :environment do
	@event = Event.find(ENV["EVENT_ID"])
	
	unless @event.nil?
		@event.attendees.each do |attendee|
			# puts "#{attendee.name} - #{attendee.accepts_event_notifications}"
			if attendee.accepts_event_notifications
				email = EventMailer.event_updated(@event, attendee).deliver
				puts "Sending notification to: #{attendee.email} ... #{email}"
			end
		end
	else
		puts "Could not find event by ID"
	end
end