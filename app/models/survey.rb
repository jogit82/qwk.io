class Survey
  include Mongoid::Document

  field :surveyid, :type => Integer
  field :adminkey, :type => String
  field :rawtext, :type => String
  field :closed, :type => Boolean, :default => false
  # field :response_count, :type => Integer, :default => 0

  index :surveyid, :unique => true
  index :adminkey, :unique => true

  validates_presence_of :surveyid
  validates_presence_of :adminkey

  def responses
    @response_cache || (@response_cache = Response.where(:surveyid => self._id))
  end

  #Obsolete, we can use this again if we decide to keep response counts on the survey document
  def self.inc_count(survey)
    collection.update( {'_id' => survey[:_id]}, {'$inc' => {'response_count' => 1}} )
  end
end