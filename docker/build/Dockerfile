FROM fml-ruby

WORKDIR /fml

RUN apk add --no-cache -u \
  git \
  ruby-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  libffi-dev \
  postgresql-dev \
  nodejs-current \
  yarn \
  libuv


CMD ["/fml/build.sh"]

VOLUME ["/fml"]
