FROM registry.access.redhat.com/rhel7:latest
ARG VERSION=1.9.0

# Inspiration from https://github.com/gmr/alpine-pgbouncer/blob/master/Dockerfile

USER root
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms

RUN yum install -y wget
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y epel-release-latest-7.noarch.rpm
RUN yum repolist

RUN yum install -y autoconf automake udns udns-devel curl gcc glibc-devel libevent libevent-devel libtool make man openssl-devel pkgconfig postgresql

RUN curl -o  /tmp/pgbouncer-$VERSION.tar.gz -L https://pgbouncer.github.io/downloads/files/$VERSION/pgbouncer-$VERSION.tar.gz

WORKDIR /tmp
RUN tar xvfz /tmp/pgbouncer-$VERSION.tar.gz

WORKDIR /tmp/pgbouncer-$VERSION
RUN ./configure --prefix=/usr --with-udns
RUN make && make install

RUN mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer

# entrypoint installs the configuation, allow to write as postgres user
RUN adduser postgres
RUN chown -R postgres /var/run/pgbouncer /etc/pgbouncer

# cleanup
RUN rm -rf /tmp/pgbouncer* 
RUN yum clean all && rm -rf /var/cache/yum

ADD entrypoint.sh /entrypoint.sh
USER postgres
EXPOSE 5432
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
