FROM fml-ruby

WORKDIR /fml

RUN apk add --no-cache -u \
  libpq

CMD ["bundle", "exec", "puma"]

VOLUME ["/fml"]
