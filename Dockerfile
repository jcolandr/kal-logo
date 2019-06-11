FROM alpine:3.9
#FROM alpine:3.2

LABEL maintainer=joe.colandro@docker.com

RUN apk add --update --no-cache nginx

RUN mkdir -p /var/lib/nginx/html/img /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/lib/nginx/html/index.html
COPY /img/*.png /var/lib/nginx/html/img/

EXPOSE 80

CMD ["nginx"]