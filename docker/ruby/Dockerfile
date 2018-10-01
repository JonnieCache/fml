FROM alpine:3.7

RUN mkdir -p /etc \
  && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /etc/gemrc

RUN apk add --no-cache -u \
  ruby \
  ruby-json \
  ruby-io-console \
  ruby-irb

RUN gem install bundler
RUN bundle config --global silence_root_warning 1

CMD ["irb"]
