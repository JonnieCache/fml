FROM ruby:2.6.3-alpine3.9

RUN mkdir -p /etc \
  && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /etc/gemrc

RUN apk add -u \
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
  # yarn \
  libuv \
  libpq

WORKDIR /tmp

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install --without development

COPY package.json package.json
COPY package-lock.json package-lock.json
# COPY yarn.lock yarn.lock
# RUN yarn install --production=true
RUN npm install --production

COPY webpack.config.babel.js webpack.config.babel.js
COPY .babelrc .babelrc
COPY app/assets app/assets
RUN $(npm bin)/webpack -p

WORKDIR '/fml'
COPY . '/fml'
RUN mv /tmp/public/assets/* /fml/public/assets/

CMD ["bundle", "exec", "puma"]
