require 'fastercsv'
require 'json'
require 'active_model/serializers/xml'

module SurveysHelper
  class NoQuestionsError < RuntimeError
  end

  class SurveyRender
    attr_accessor :survey, :title, :description, :questions

    def initialize(survey)
      @survey = survey
      @title = nil
      @description = nil

      #regular expressions to test what each line is
      @re_question = /^\d*\)(.*)$/
      @re_multichoice = /^\[ \](.*)$/
      @re_radio = /^\( \)(.*)$/
      @re_dropdown = /^\< \>(.*)$/
      @re_textbox = /^_{3,}\s*$/
      @re_pointrating = /^(\(\d+\)\s*){3,10}$/

      compile
    end

    def compile
      @questions = []
      curQuestion = nil
      idx = 0

      @survey.rawtext.each_line do |line|
        line.strip!

        if (line.empty?)
          next
        end

        is_questionheader = @re_question.match(line)
        is_multichoice = @re_multichoice.match(line)
        is_radio = @re_radio.match(line)
        is_dropdown = @re_dropdown.match(line)
        is_textbox = @re_textbox.match(line)
        is_pointrating = @re_pointrating.match(line)

        if (is_questionheader) # line is question header
          curQuestion = {} # start a new question
          curQuestion[:idx] = (idx += 1)

          @questions.push curQuestion
          curQuestion[:title] = is_questionheader.captures[0].strip # title of question
        elsif (is_multichoice && curQuestion) # line is multiple choice checkbox
          curQuestion[:type] ||= 'checkbox'
          curQuestion[:options] ||= []
          curQuestion[:options].push is_multichoice.captures[0]
        elsif (is_radio && curQuestion) # line is radio options
          curQuestion[:type] ||= 'radio'
          curQuestion[:options] ||= []
          curQuestion[:options].push is_radio.captures[0]
        elsif (is_dropdown && curQuestion) # line is dropdown
          curQuestion[:type] ||= 'dropdown'
          curQuestion[:options] ||= []
          curQuestion[:options].push is_dropdown.captures[0]
        elsif (is_textbox && curQuestion) # line is text input box
          if (curQuestion[:type] == 'singleline') # already have a singleline, so let's upgrade it to a multiline
            curQuestion[:type] = 'multiline'
          else
            curQuestion[:type] = 'singleline' unless curQuestion[:type] == 'multiline'
          end
        elsif (is_pointrating && curQuestion) # line is point rating
          curQuestion[:type] = 'pointrating'
          curQuestion[:points] = line.scan('(').count
        elsif (curQuestion && !curQuestion[:type]) #no format match, but we're in a question - make this a question subtext
          curQuestion[:subtitle] = line
        elsif (curQuestion == nil)
          if(@title == nil)
            @title = line
            next
          end

          @description = line
        end
      end

      if (questions.count == 0) # No questions, WTF?
        raise NoQuestionsError
      end
    end

    def to_csv
      #pivots the responses in the survey
      map = { }
      @survey.responses.each do |r|
        userkey = r['userkey']
        map[userkey] ||= { :timestamp => r['timestamp'], :answers => Array.new(@questions.length) }
        r['answers'].each do |a|map[userkey][:answers][a['question'] - 1] = a['answer'] end
      end

      #generate csv string
      csv = FasterCSV.generate do |r|
        #build header row
        headers = ["User Key", "Timestamp"]
        @questions.each do |q| headers.push( q[:title]) end
        r << headers

        map.keys.sort_by { |k| map[k][:timestamp] }.each do |user|
          r << [user, map[user][:timestamp]] + map[user][:answers]
        end
      end

      csv
    end

    def to_json
      #pivots the responses in the survey
      map = { }
      @survey.responses.each do |r|
        userkey = r['userkey']
        map[userkey] ||= { :timestamp => r['timestamp'], :answers => Array.new(@questions.length) }
        r['answers'].each do |a|map[userkey][:answers][a['question'] - 1] = a['answer'] end
      end

      {
          :responses => map,
          :questions => @questions.collect { |q| { :idx => q[:idx], :title => q[:title] } },
          :title => @title,
          :description => @description
      }.to_json
    end

    def to_xml
      #pivots the responses in the survey
      map = { }
      @survey.responses.each do |r|
        userkey = r['userkey']
        map[userkey] ||= { :timestamp => r['timestamp'], :answers => Array.new(@questions.length), :userkey => r['userkey'] }
        r['answers'].each do |a|map[userkey][:answers][a['question'] - 1] = a['answer'] end
      end

      {
        :responses => map.values.to_a,
        :questions => @questions.collect { |q| { :idx => q[:idx], :title => q[:title] } },
        :title => @title,
        :description => @description
      }.to_xml :root => 'survey'
    end
  end
end
