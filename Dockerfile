# This dockerfile builds an image for running phabricator.
# It is inspired by the RedpointGames/phabricator image. Differences:
# - Based on debian instead of opensuse
# - Does not include mail server of notification server
# - Relies on reverse proxy for SSL termination

FROM debian:latest

# We expose port 80 to be reached only by the reverse proxy, and port
# 22 to be mapped to some other port on the host for repository
# hosting.
EXPOSE 80 22

# install software packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&                                                         \
    apt-get install -y git nginx nginx php-fpm python-pygments python-chardet \
                       php-apcu php-fpm supervisor mariadb-client
RUN adduser phabricator --uid 2000 --ingroup www-data
RUN cat /etc/passwd                                                    && \
    cat /etc/group 

# baseline/setup.sh installs the necessary software packages
COPY baseline /baseline
RUN /baseline/setup.sh

COPY preflight /preflight
RUN /preflight/setup.sh
CMD ["/bin/bash", "/app/init.sh"]