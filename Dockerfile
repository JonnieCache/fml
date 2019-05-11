FROM fml-ruby

RUN apk add -u \
  git \
  ruby-dev \
  python2 \
  libsass-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  libffi-dev \
  postgresql-dev \
  nodejs-current \
  # yarn \
  libuv \
  libpq

RUN gem install bundler
RUN bundle config --global silence_root_warning 1

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install --without development

COPY package.json package.json
COPY package-lock.json package-lock.json
# COPY yarn.lock yarn.lock
# RUN yarn install --production=true
RUN npm install --global --production=true

COPY webpack.config.babel.js webpack.config.babel.js
COPY .babelrc .babelrc
COPY app/assets app/assets
RUN $(yarn bin)/webpack -p

WORKDIR '/fml'
COPY . '/fml'
# RUN mv /tmp/vendor /fml/
# RUN mv /tmp/bin /fml/
# RUN mv /tmp/node_modules /fml/
# RUN cp -R /tmp/assets/* /fml/public/assets/

CMD ["bundle", "exec", "puma"]
