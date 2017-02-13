class Survey
  include Mongoid::Document

  auto_increment :surveyid, :collection => :surveyid, :seed => 15000
  field :adminkey, :type => String
  field :rawtext, :type => String
  field :closed, :type => Boolean, :default => false

  index({ surveyid: 1 }, { unique: true, name: "surveyid_index" })
  index({ adminkey: 1 }, { unique: true, name: "adminkey_index" })

  validates_presence_of :adminkey

  def responses
    @response_cache || (@response_cache = Response.where(:surveyid => self._id))
  end
end
