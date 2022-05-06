FROM alpine:3.15

RUN adduser -D -u 1000 amplify
RUN apk --update --no-cache add util-linux ca-certificates nginx

COPY --chown=amplify:amplify etc /etc

# We need to create and chown these directory for
# readonly and non-root execution.
RUN mkdir -p /run/nginx /var/tmp/nginx
RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN chown -R amplify:amplify /var/lib/nginx \
    /var/log/nginx \
    /var/tmp/nginx \
    /var/lib/nginx/tmp \
    /var/lib/nginx/logs \
    /usr/lib/nginx/modules \
    /run/nginx

# Declaring these here means they inherit the "chown"
# directive from above.
VOLUME /run/nginx
VOLUME /var/tmp/nginx
VOLUME /var/lib/nginx/tmp

EXPOSE 8080

STOPSIGNAL SIGTERM

USER amplify

CMD ["nginx"]
