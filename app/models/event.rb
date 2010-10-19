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
    sources = [:native]

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

end