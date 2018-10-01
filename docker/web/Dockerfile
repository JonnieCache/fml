FROM nginx:alpine

COPY nginx /etc/nginx/

CMD ["nginx", "-g", "daemon off;"]

VOLUME ["/fml"]
VOLUME ["/etc/ssl/acme/fml.cleverna.me/"]
