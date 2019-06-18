FROM ruby:2.6.3-alpine3.9 AS build

RUN apk add --no-cache \
  build-base \
  git \
  python2 \
  libsass-dev \
  libxml2-dev \
  libxslt-dev \
  libffi-dev \
  postgresql-dev \
  nodejs-current \
  npm \
  libuv

WORKDIR /tmp

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN gem install bundler:2.0.1
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install --no-cache --jobs=4 --deployment --binstubs --without development

COPY package.json package.json
COPY package-lock.json package-lock.json
RUN npm install --no-cache --production

COPY webpack.config.babel.js webpack.config.babel.js
COPY .babelrc .babelrc
COPY app/assets app/assets
RUN $(npm bin)/webpack -p

FROM ruby:2.6.3-alpine3.9 AS production

RUN apk add --no-cache \
  libpq

WORKDIR '/fml'
COPY . '/fml'
COPY --from=build /tmp/public/assets/* /fml/public/assets/
COPY --from=build /tmp/vendor /fml/vendor
COPY --from=build /tmp/bin /fml/bin
COPY --from=build /usr/local/bundle/config /usr/local/bundle/config

CMD ["bundle", "exec", "puma"]

FROM production AS test

RUN apk add --no-cache \
  chromium \
  chromium-chromedriver

CMD ["./ci-rspec.sh"]

FROM production
