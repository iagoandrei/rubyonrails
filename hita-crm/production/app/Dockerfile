# These configurations will install the requirements, copy the project to the docker container
# install the gems, precompile the assets, and run puma

FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs
RUN npm install yarn -g
RUN yarn add @uppy/core @uppy/dashboard @uppy/xhr-upload jquery jquery-ui-bundle slick-carousel
RUN npm i jquery-mask-plugin @chenfengyuan/datepicker tributejs @fullcalendar/core @fullcalendar/daygrid

ENV RAILS_ROOT /hita-crm
RUN mkdir -p $RAILS_ROOT

WORKDIR $RAILS_ROOT

ENV RAILS_ENV=production
ENV RACK_ENV=production

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN gem install bundler:2.0.2
RUN bundle install --jobs 20 --retry 5 --without development test

COPY . .
RUN bundle exec rake assets:precompile
RUN bundle exec rake webpacker:compile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
