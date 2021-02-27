# This file install dependencies of the nginx, create the log

FROM nginx

RUN apt-get update -qq && apt-get -y install apache2-utils

# rails directory inside the nginx image
ENV RAILS_ROOT /hita-crm
WORKDIR $RAILS_ROOT

RUN mkdir log/
RUN mkdir log/nginx
RUN touch log/nginx/nginx.access.log

# Copy static assets
COPY public public/

# copy nginx config template
COPY production/nginx/nginx.conf /tmp/docker.nginx

# substitute variable references in the Nginx config template for real values from the environment
# put the final config in its place
RUN envsubst '$RAILS_ROOT' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf

EXPOSE 80

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]