class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_404
    @header = 'Huh?'
    @message = 'We\'ve looked and looked, but just can\'t find the page you\'re looking for...'

    respond_to do |format|
      format.html { render :template => '/home/message.html.erb' }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def render_badsurvey
    @header = 'Invalid survey'
    @message = 'You must enter at least one survey question.'

    respond_to do |format|
      format.html { render :template => '/home/message.html.erb' }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def render_closed
    @header = 'Survey Closed'
    @message = 'This survey has been closed and is no longer accepting responses.'

    respond_to do |format|
      format.html { render :template => '/home/message.html.erb' }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end
end
