require 'uuidtools'

class SurveysController < ApplicationController
  # route for /xxxx (what user will use to take an existing survey)
  def take
    @no_follow = true # If Google finds this link, tell it not to index or follow
    surveyid = params[:id].to_i(36)
    if(surveyid == 0) #bad Base36 number on URL
      render_404
      return
    end

    survey = Survey.where(:surveyid => surveyid).only(:rawtext, :closed)[0]
    if (survey == nil)
      render_404
      return
    end

    @rendering = SurveysHelper::SurveyRender.new(survey)
    @page_title = (@rendering.title || "Unnamed Survey") + " (Qwk.io)"

    #Set Facebook OpenGraph tags so people can post this on their wall
    @og_title = @page_title
    @og_desc = @rendering.description || '' #Do we want some sort of default description here?
    @og_url = "http://qwk.io#{request.fullpath}"

    if(survey.closed?)
      render_closed
      return
    end


    respond_to do |format|
      format.html # take.html.erb
    end
  end


  # route for POST /xxxx (user responds to a survey)
  def respond
    surveyid = params[:id].to_i(36)
    if(surveyid == 0) #bad Base36 number on URL
      render_404
      return
    end

    survey = Survey.where(:surveyid => surveyid).only(:rawtext, :closed)[0]
    if (survey == nil)
      render_404
      return
    end

    if(survey.closed?)
      render_closed
      return
    end

    response = Response.new
    uk = UUIDTools::UUID.timestamp_create.hexdigest.to_s # unique key for this response batch
    response[:surveyid] = survey[:_id]
    response[:userkey] = UUIDTools::UUID.timestamp_create.hexdigest.to_s # unique key for this response batch
    response[:timestamp] = Time.now
    response[:answers] = []

    answers = params[:Q]
    answers.each_key do |a|
      answer = answers[a]
      db_answer = { :question => a.to_i }

      if (answer.class == String) #just record the answer as is
        db_answer[:answer] = answer
      end

      if (answer.respond_to?(:keys)) #convert into a comma delimited list
        db_answer[:answer] = answer.keys.to_a.join(',')
      end

      response[:answers] << db_answer
    end

    # Survey.respond(survey, response)
    response.save

    respond_to do |format|
      format.html
    end
  end

  # POST /surveys
  def create
    @survey = Survey.new
    @ak = UUIDTools::UUID.timestamp_create.to_s
    surveyid = SurveyId.first.safely.inc(:nextid, 1) # TODO: If running on multiple servers, we need a dedicated "survey id generator" in the cluster

    @survey[:surveyid] = surveyid # auto-incremementing server ID used for URL lookups
    @survey[:adminkey] = Digest::MD5.digest(@ak).unpack("Q")[0].to_s(36) # 64bit hash for admins
    @survey[:rawtext] = params[:survey]

    #compile this survey to check for errors
    begin
      SurveysHelper::SurveyRender.new(@survey)
    rescue SurveysHelper::NoQuestionsError
      render_badsurvey
      return
    end

    respond_to do |format|
      if @survey.save!
        format.html
      else
        raise 'Could not save survey!' # TODO: Handle error
      end
    end
  end

  def results
    @no_follow = true # If Google finds this link, tell it not to index or follow
    survey = Survey.where(:adminkey => params[:id])[0]
    if (survey == nil)
      render_404
      return
    end

    @rendering = SurveysHelper::SurveyRender.new(survey)
    #We don't store response count in Survey to avoid document locking when user responds, though results page is slightly slower
    @count = Response.where(:surveyid => survey[:_id]).count
    @closed = survey.closed

    respond_to do |format|
      format.html # results.html.erb
      format.csv { render :text => @rendering.to_csv }
      format.json { render :json => @rendering.to_json }
      format.xml { render :xml => @rendering.to_xml }
    end
  end

  def toggle
    @no_follow = true # If Google finds this link, tell it not to index or follow
    survey = Survey.where(:adminkey => params[:id]).only(:adminkey, :surveyid).limit(1)[0]
    if (survey == nil)
      render_404
      return
    end

    survey.update_attributes!(:closed => params[:state])

    respond_to do |format|
      format.html { redirect_to(results_url(:id => survey.adminkey)) }
      format.json { render :json => { :Closed => params[:state] } }
      format.xml { render :xml => { :Closed => params[:state] } }
    end
  end
end
