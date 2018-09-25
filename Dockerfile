FROM nginx:latest

# Install the NGINX Amplify Agent
RUN apt-get update \
    && apt-get install -qqy curl python apt-transport-https apt-utils gnupg1 procps

RUN echo 'deb https://packages.amplify.nginx.com/debian/ stretch amplify-agent' > /etc/apt/sources.list.d/nginx-amplify.list

RUN curl -fs http://nginx.org/keys/nginx_signing.key | apt-key add - > /dev/null 2>&1

RUN apt-get update \
    && apt-get install -qqy nginx-amplify-agent \
    && apt-get purge -qqy curl apt-transport-https apt-utils gnupg1 \
    && rm -rf /var/lib/apt/lists/*

# Keep the nginx logs inside the container
RUN unlink /var/log/nginx/access.log \
    && unlink /var/log/nginx/error.log \
    && touch /var/log/nginx/access.log \
    && touch /var/log/nginx/error.log \
    && chown nginx /var/log/nginx/*log \
    && chmod 644 /var/log/nginx/*log

# Copy nginx stub_status config
COPY ./conf.d/stub_status.conf /etc/nginx/conf.d

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir /code
WORKDIR /code

COPY entrypoint.sh /code

CMD ["./entrypoint.sh"]

EXPOSE 80
EXPOSE 443
