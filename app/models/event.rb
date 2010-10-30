require 'net/http'
require 'net/https'
require 'rubygems'
require 'json'
require 'uri'

class Event < ActiveRecord::Base
  has_many :groups

    

   define_index do
    # fields
    indexes :name, :sortable => true
    indexes :slug
    indexes :description
    indexes :location, :sortable => true

    # attributes
    has created_at, updated_at, starts_at, ends_at
  end


  def self.event_find(query, location = "")

    sources = [:meetup]
    lat, lng = ""
    #get the latlong for the location passed in, this will make lookup a lot easier
    if !location.nil? && !location.empty?
      latlong_uri = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.escape(location)}&sensor=false")
      latlong = Net::HTTP.get_response(latlong_uri)

      location = JSON.parse(latlong.body)

      lng = location['results'].first['geometry']['location']['lng'] rescue ""
      lat = location['results'].first['geometry']['location']['lat'] rescue ""
    end

    @results = []
    if !query.to_s.strip.empty? || !location.to_s.strip.empty?
      sources.each do |source|
       @results << (self.method( source ).call(query, lat, lng).collect{ |r| r }.collect{|result| result}) || []
      end
    end
    @results.flatten.uniq.compact.flatten

  end


  def self.native(q, lat = "", lng = "")
    if lat.empty? || lng.empty?
       Event.search q, :match_mode => :boolean
    else
       Event.search q, :conditions => {:location => location}, :match_mode => :boolean
    end
  end

  #TODO: Do we really need an API key for this?
  #TODO: Add a link here - this whole thing could be more robust re: info collected
  def self.meetup(q, lat = "", lng = "")

    #get the latlong for the location passed in, this will make lookup a lot easier
    if lat.blank? || lng.blank?
      query_uri = URI.escape("https://api.meetup.com/2/open_events.json?text=#{q}&key=717541311e433f517204e38795d6f")
    elsif q.empty?
      query_uri = URI.escape("https://api.meetup.com/2/open_events.json?lat=#{lat}&lon=#{lng}&radius=50&key=717541311e433f517204e38795d6f")
    else
      query_uri = URI.escape("https://api.meetup.com/2/open_events.json?text=#{q}&lat=#{lat}&lon=#{lng}&radius=50&key=717541311e433f517204e38795d6f")
    end

    url = URI.parse(query_uri);
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true;
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)

    events = JSON.parse(response.body)

    results = []

    events["results"].each do |event|
     results << Event.new(:name=> event['name'],
                :description => event['description'],
                :location => (event['venue']['name'] rescue ""),
                :starts_at => event['time'],
                :ends_at => event['time'],
                :remote_source => "meetup",
                :remote_id => event['id'])
    end

    return_results = []

    results.each do |result|
      saved_result = Event.find_by_remote_id_and_remote_source(result[:remote_id], result[:remote_source])
      if !saved_result.nil?
        return_results << saved_result
      else
        result.save!
        return_results << result
      end
    end
    
    return_results
  end

  def self.eventbrite(q, lat = "", lng = "")

    if lat.empty? || lng.empty?
      query_uri = URI.escape("https://www.eventbrite.com/json/event_search?keywords=#{q}&app_key=ZDRiMTBjYWVkYjA4")
    else
      query_uri = URI.escape("https://www.eventbrite.com/json/event_search?keywords=#{q}&latitude=#{lat}&longitude=#{lng}&within=50&within_unit=K&app_key=ZDRiMTBjYWVkYjA4")
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

      next if event["event"].nil?

     results << Event.new(:name=> event['event']['title'],
                :description => event['event']['description'],
                :location => (event['event']['timezone'] rescue ""),
                :starts_at => event['event']['start_date'],
                :ends_at => event['event']['end_date'],
                :remote_source => "eb",
                :remote_id => event['event']['id'])
    end

    return_results = []

    results.each do |result|
      saved_result = Event.find_by_remote_id_and_remote_source(result[:remote_id], result[:remote_source])
      if !saved_result.nil?
        return_results << saved_result
      else
        result.save!
        return_results << result
      end
    end
    
    return_results
  end

end