class SurveyId
  include Mongoid::Document
  store_in 'surveyid'
  
  field :nextid, :type => Integer, :default => 15000
  identity :type => Integer
end
