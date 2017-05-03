FROM jgoerzen/qemu
MAINTAINER John Goerzen <jgoerzen@complete.org>
RUN mkdir /tmp/setup
COPY setup/sums /tmp/setup
# Do the download ASAP so we don't hit the download sites overly hard
COPY download.sh /tmp/download.sh
RUN /tmp/download.sh

RUN apt-get update
RUN apt-get -y -u dist-upgrade
RUN apt-get -y --no-install-recommends install \
            fatresize mtools dosfstools samba diffutils dos2unix patch
COPY scripts/ /usr/local/bin/
COPY supervisor/ /etc/supervisor/conf.d/
COPY setup/ /tmp/setup/
RUN /tmp/setup/setup.sh
RUN /tmp/setup/prepimages.sh
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY smb.conf /etc/samba/smb.conf

# Dosemu was just used to grab FreeDOS stuff.
RUN rm -r /tmp/download.sh /tmp/setup

EXPOSE 5901
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

