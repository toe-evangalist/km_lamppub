FROM nginx:stable

HEALTHCHECK NONE

WORKDIR /usr/share/nginx/html/css
COPY nginx/css/ .

WORKDIR /usr/share/nginx/html
COPY nginx/index.html .

WORKDIR /usr/share/nginx/html/images
COPY nginx/images/ .

WORKDIR /tmp
COPY nginx/nginx.conf .

RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# uncomment the user to make the build pass!
# USER nginx
CMD /bin/bash -c "envsubst < /tmp/nginx.conf > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"