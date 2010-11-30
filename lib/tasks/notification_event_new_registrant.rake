desc "Notification to let Event owner know that there is a new attendee"
task :notification_event_new_registrant => :environment do
	@event = Event.find(ENV["EVENT_ID"])
	@registrant = User.find(ENV["REGISTRANT_ID"])
	
	unless @event.nil?
		unless @event.administrator.nil?
			email = EventMailer.new_registrant(@event, @registrant).deliver
			puts "Notifying Event admin of new registrant. #{email}"
		end
	end

end