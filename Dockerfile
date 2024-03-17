FROM ruby:3.0
RUN apt-get update -qq && apt-get install -y nodejs npm
RUN npm install --global yarn
WORKDIR /DroneAPI
COPY Gemfile /DroneAPI/Gemfile
COPY Gemfile.lock /DroneAPI/Gemfile.lock
RUN bundle install
COPY . /DroneAPI