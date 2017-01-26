require 'date'
require 'time'

class Response
  include Mongoid::Document

  field :surveyid, :type => Object
  field :userkey, :type => String
  field :answers, :type => Array
  field :timestamp, :type => Time

  index :surveyid

  validates_presence_of :surveyid
  validates_presence_of :userkey
end
