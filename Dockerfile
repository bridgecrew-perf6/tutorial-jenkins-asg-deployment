FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Fix timezone issue
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install updates/packages
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y vim cron apache2 curl unzip git

# expose port 80 and 443 (ssl) for the web requests
EXPOSE 80

# Manually set the apache environment variables in order to get apache to work immediately.
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# It appears that the new apache requires these env vars as well
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid

# Add the site's code to the container.
# We could mount it with volume, but by having it in the container, deployment is easier.
COPY --chown=root:www-data app /var/www/my-site

# Update our apache sites available with the config we created
ADD docker/apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Use the crontab file.
# The crontab file was already added when we added "project"
#RUN crontab /var/www/my-site/project/docker/crons.conf

RUN chown root:www-data /var/www && chmod 750 -R /var/www

# Execute the containers startup script which will start many processes/services
# The startup file was already added when we added "project"
COPY --chown=root:root docker/startup.sh /root/startup.sh
CMD ["/bin/bash", "/root/startup.sh"]
