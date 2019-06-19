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

RUN bundle install --no-cache --jobs=4 --deployment --binstubs --without development \
&& find vendor/bundle/ -name ".git" -exec rm -r {} + \
&& find vendor/bundle/ -name "*.c" -delete \
&& find vendor/bundle/ -name "*.o" -delete \
&& rm -rf vendor/bundle/ruby/*/cache

COPY package.json package.json
COPY package-lock.json package-lock.json
RUN npm install --no-cache --production

COPY webpack.config.babel.js webpack.config.babel.js
COPY .babelrc .babelrc
COPY app/assets app/assets
RUN $(npm bin)/webpack -p

FROM ruby:2.6.3-alpine3.9 as base

RUN gem install bundler:2.0.1
RUN apk add --no-cache \
  libpq

FROM base AS test

RUN apk add --no-cache \
  chromium \
  chromium-chromedriver

WORKDIR '/fml'
COPY . '/fml'
COPY --from=build /tmp/public/assets/* /fml/public/assets/
COPY --from=build /tmp/vendor /fml/vendor
COPY --from=build /tmp/bin /fml/bin
COPY --from=build /usr/local/bundle/config /usr/local/bundle/config

CMD ["./ci-rspec.sh"]

FROM base AS production

WORKDIR '/fml'
COPY --from=test /fml /fml
COPY --from=test /usr/local/bundle/config /usr/local/bundle/config

CMD ["bundle", "exec", "puma"]
