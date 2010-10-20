require 'net/http'
require 'net/https'
require 'rubygems'
require 'json'
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

  def self.event_find(query)
    sources = [:native, :eventbrite, :meetup]

    @results = []
    if !query.to_s.strip.empty?
      sources.each do |source|
       @results << (self.method( source ).call(query).collect{ |r| r }.collect{|result| result}) || []
      end
    end
    @results.flatten
  end

  def self.native(q)
    Event.search q, :match_mode => :boolean
  end

  #TODO: Do we really need an API key for this?
  #TODO: Add a link here - this whole thing could be more robust re: info collected
  def self.meetup(q)

    query_uri = "https://api.meetup.com/2/open_events.json?text=#{q}&key=717541311e433f517204e38795d6f"
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
                :ends_at => event['time'])
    end

    results
  end

  def self.eventbrite(q)
    query_uri = "https://www.eventbrite.com/json/event_search?keywords=#{q}&app_key=ZDRiMTBjYWVkYjA4"
    url = URI.parse(query_uri);
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true;
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
                :ends_at => event['event']['end_date'])
    end

    results

  end

end