ARG UBUNTUVERSION=focal

FROM ubuntu:$UBUNTUVERSION

# ARGs declared before FROM are in a different scope, so need to be stated again
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG UBUNTUVERSION
ARG REPO=https://stable.apt.unified-streaming.com
ARG VERSION=1.11.1

# noninteractive installs
ENV DEBIAN_FRONTEND=noninteractive

# Install wget and gnupg
RUN apt-get update \
        &&  apt-get install -y \
        wget \
        gnupg \
        unzip

# Add tears of steel first for Docker build/cache purposes
# RUN wget http://repository.unified-streaming.com/tears-of-steel.zip

# RUN mkdir -p /var/www/unified-origin \
# &&  unzip tears-of-steel.zip -d /var/www/unified-origin

RUN mkdir -p /var/www/unified-origin

# Add the Unified Streaming public key
RUN wget $REPO/unifiedstreaming.pub \
        &&  apt-key add unifiedstreaming.pub

# Add repository
RUN echo "deb [arch=amd64] $REPO $UBUNTUVERSION multiverse" > /etc/apt/sources.list.d/unified-streaming.list

# Install Origin
RUN apt-get update \
        &&  apt-get install -y \
        apache2 \
        mp4split=$VERSION \
        libapache2-mod-smooth-streaming=$VERSION

# Set up directories and log file redirection
RUN mkdir -p /run/apache2 \
        &&  rm -f /var/log/apache2/error.log \
        &&  ln -s /dev/stderr /var/log/apache2/error.log \
        &&  rm -f /var/log/apache2/access.log \
        &&  ln -s /dev/stdout /var/log/apache2/access.log


# Enable extra modules and disable default site
RUN a2enmod \
        headers \
        proxy \
        ssl \
        mod_smooth_streaming \
        && a2dissite 000-default

# Copy apache config and entrypoint script
COPY unified-origin.conf.in /etc/apache2/sites-enabled/unified-origin.conf.in
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["-D", "FOREGROUND"]