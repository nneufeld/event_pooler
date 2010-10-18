class Event < ActiveRecord::Base
  has_many :groups

  def self.search(query)
    sources = [:native]
    results = []
    sources.each do |source|
     results << self.method( source ).call(query).collect{ |r| r }
    end
    p "HELLO THERE!"
  end

  def self.native(q)
   if !q.to_s.strip.empty?
      find_by_sql(["select e.* from events e where e.name like '#{q}'"]);
   else
      []
   end
  end

end