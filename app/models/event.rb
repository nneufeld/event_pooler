require 'rubygems'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'
require 'nokogiri'

class Event < ActiveRecord::Base
  has_many :groups
  has_many :user_review
  belongs_to :administrator, :class_name => 'User'

  scope :attended_by, lambda {|user|
    event_group_type = GroupType.find_by_slug('event')
    joins('INNER JOIN groups g ON g.event_id = events.id INNER JOIN memberships m ON m.group_id = g.id').
    where(['g.group_type_id = ? AND m.user_id = ?', event_group_type.id, user.id])
  }


   scope :closest_to_user, lambda {|user|
    unless user.nil?
      latitude = user.latitude
      longitude = user.longitude
      if latitude.nil? || longitude.nil?
        ip_addr = request.env['REMOTE_ADDR']
        geo = Geokit::Geocoders::IpGeocoder.geocode(ip_addr)
        latitude = geo.lat
        longitude = geo.long
      end
      unless latitude.nil? || longitude.nil?
        select('DISTINCT events.*').geo_scope(:origin => [user.latitude, user.longitude]).order('distance')
      end
    end
  }


  define_index do

    # attributes
    has created_at, updated_at, starts_at, ends_at
    has "RADIANS(latitude)",  :as => :latitude,  :type => :float
    has "RADIANS(longitude)", :as => :longitude, :type => :float

    # fields
    indexes :name, :sortable => true
    indexes :slug
    indexes :description
    #indexes :location, :sortable => true
  end


  def self.event_find(query, location = "")

    sources = [:native, :meetup, :eventbrite]
    lat, lng = ""

    #get the latlong for the location passed in, this will make lookup a lot easier
    if !location.nil? && !location.blank?
      latlong_uri = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.escape(location)}&sensor=false")
      latlong = Net::HTTP.get_response(latlong_uri)

      location = JSON.parse(latlong.body)

      lng = location['results'].first['geometry']['location']['lng'] rescue ""
      lat = location['results'].first['geometry']['location']['lat'] rescue ""
      wlat = location['results'].first['geometry']['viewport']['southwest']['lat']
      elat = location['results'].first['geometry']['viewport']['northeast']['lat']
      slng = location['results'].first['geometry']['viewport']['southwest']['lng']
      nlng = location['results'].first['geometry']['viewport']['northeast']['lng']
    end



    @results = []
    if !query.to_s.strip.blank? || !location.to_s.strip.blank?
      sources.each do |source|
        begin
          Timeout::timeout(20) do
            @results << (self.method( source ).call(query, {:lat => lat, :lng => lng, :wlat => wlat, :elat => elat, :nlng => nlng, :slng => slng}).collect{ |r| r }.collect{|result| result}) || []
          end
        rescue Exception => ex
          puts "Error getting results from #{source.to_s}"
        end
      end
    end
    @results.flatten.uniq.compact.flatten

  end


  def self.native(q = "", location = {})
    results = []
    if location[:lat].blank? || location[:lng].blank?
       results = Event.search q, :match_mode => :boolean
    else
      results = Event.search q,
      :with => { :starts_at => Time.now().to_i...Time.now().to_i + 7952400, "@geodist" => 0.0..100000.0 },
      :geo => [location[:lat] * Math::PI / 180, location[:lng] * Math::PI / 180], # thinking_sphinx expects lat and long in radians
      :match_mode => :boolean
    end

    results
  end

  #TODO: Do we really need an API key for this?
  #TODO: Add a link here - this whole thing could be more robust re: info collected
  def self.meetup(q, location = {})

    #get the latlong for the location passed in, this will make lookup a lot easier
    if location[:lat].blank? || location[:lng].blank?
      query_uri = URI.escape("https://api.meetup.com/2/open_events.xml?text=#{q}&key=717541311e433f517204e38795d6f")
    elsif q.blank?
      query_uri = URI.escape("https://api.meetup.com/2/open_events.xml?lat=#{location[:lat]}&lon=#{location[:lng]}&radius=50&key=717541311e433f517204e38795d6f")
    else
      query_uri = URI.escape("https://api.meetup.com/2/open_events.xml?text=#{q}&lat=#{location[:lat]}&lon=#{location[:lng]}&radius=50&key=717541311e433f517204e38795d6f")
    end

    url = URI.parse(query_uri);
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true;
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)

    events = Nokogiri::XML.parse(response.body)

    results = []

    events.search('items').search('item').each do |item|

     next if item.search('venue').blank? #don't show if we don't know where it is

    results << Event.new(
                :name=> item.search('group').search('name').inner_html,
                :description => item.search('description').inner_html,
                :starts_at => Time.at(item.search('time').text.to_i/1000),
                :ends_at => "",
                :remote_source => "meetup",
                :remote_id => item.search('id').inner_html,
                :address => (item.search('venue').search('address_1').inner_html rescue ""),
                :city => (item.search('venue').search('city').inner_html rescue ""),
                :region => (item.search('venue').search('state').inner_html rescue ""),
                :code => (item.search('venue').search('zip').inner_html rescue ""),
                :phone => "",
                :email => "",
                :url => (item.search('event_url').inner_html rescue ""),
                :latitude => (item.search('venue').search('lat').text rescue location[:lat]),
                :longitude => (item.search('venue').search('lon').text rescue location[:lng]))
    end

    return_results = []

    results.each do |result|
      saved_result = Event.find_by_remote_id_and_remote_source(result[:remote_id], result[:remote_source])
      if !saved_result.nil?
        saved_result.attributes = result.attributes
        saved_result.save!
        return_results << saved_result
      else
        result.save!
        return_results << result
      end
    end
    
    return_results
  end

  def self.eventbrite(q, location = {})

    if location[:lat].blank? || location[:lng].blank?
      query_uri = URI.escape("https://www.eventbrite.com/json/event_search?keywords=#{q}&app_key=ZDRiMTBjYWVkYjA4")
    else
      query_uri = URI.escape("https://www.eventbrite.com/json/event_search?keywords=#{q}&latitude=#{location[:lat]}&longitude=#{location[:lng]}&within=50&within_unit=K&app_key=ZDRiMTBjYWVkYjA4")
    end
    
    url = URI.parse(query_uri)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)

    events = JSON.parse(response.body)

    results = []

    
    events["events"].each do |event|

      next if event["venue"].nil?


     results << Event.new(
                :name=> event['event']['title'],
                :description => event['event']['description'],
                :starts_at => Time.parse(event['event']['start_date']),
                :ends_at => Time.parse(event['event']['end_date']),
                :remote_source => "eb",
                :address => (event['event']['venue']['address']),
                :city => (event['event']['venue']['city']),
                :region => (event['event']['venue']['region']),
                :code => (event['event']['venue']['postal_code']),
                :phone => "",
                :email => "",
                :url => event['event']['url'],
                :remote_id => event['event']['id'],
                :latitude => (event['event']['venue']['latitude']),
                :longitude => (event['event']['venue']['longitude'])
                )
    end

    return_results = []

    results.each do |result|
      saved_result = Event.find_by_remote_id_and_remote_source(result[:remote_id], result[:remote_source])
      if !saved_result.nil?
        saved_result.attributes = result.attributes
        saved_result.save!
        return_results << saved_result
      else
        result.save!
        return_results << result
      end
    end
    
    return_results
  end

  def event_group
    event_group_type = GroupType.find_by_slug('event')
    event_group = self.groups.where({:group_type_id => event_group_type.id}).first

    # this event doesn't have a main group yet, so create it
    if event_group.nil?
      event_group = Group.new
      event_group.event = self
      event_group.name = self.name
      event_group.slug = Event.generate_slug(self.name)
      event_group.description = 'Default event group'
      event_group.group_type = event_group_type
      event_group.save
    end

    return event_group
  end

  def attendees
    return self.event_group.users
  end

  def self.generate_slug(text)
    text = text.gsub(/[&,'\(\):\.\?!\"\\;éàË™“�?Ã©Â¢â€œ�¦„‹\$\+#=…%\/]/, '')
    text = text.gsub(' ', '-')
    text = text.downcase
    return text
  end

  def full_address
    return "#{self.address}\n#{self.city}, #{self.region}\n#{self.code}"
  end

  def safe_name
    CGI.unescapeHTML(self.name).html_safe
  end

  def native?
    return self.remote_source == 'native'
  end

end