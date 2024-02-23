FROM ruby:2.5.0
WORKDIR /usr/src/app 
COPY Gemfile Gemfile.lock ./ 
RUN bundle install 
ADD . /usr/src/app/ 
EXPOSE 3000 
CMD rails s -b 0.0.0.0
