FROM fml-ruby

WORKDIR /fml

RUN apk add --no-cache -u \
  libpq \
  chromium \
  chromium-chromedriver

CMD ["./ci-rspec.sh"]
VOLUME ["/fml"]
