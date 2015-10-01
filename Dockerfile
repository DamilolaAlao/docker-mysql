FROM ubuntu:14.04

# setup mysql
RUN apt-get update \
	&& apt-get install --assume-yes --no-install-recommends mysql-server-core-5.5 mysql-client-5.5 \
	&& apt-get download mysql-server-5.5 && dpkg-deb -R mysql-server-5.5_5.5.44-0ubuntu0.14.04.1_amd64.deb foo \
	&& cp foo/usr/bin/mysql_tzinfo_to_sql . && rm -r foo mysql-server-5.5_5.5.44-0ubuntu0.14.04.1_amd64.deb \
	&& apt-get clean && rm -r /var/lib/apt/lists/*

RUN groupadd --system mysql \
    && useradd --system --gid mysql --home /var/lib/mysql mysql \
    && mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld \
    && touch /var/log/mysql_general.log && chmod 666 /var/log/mysql_general.log \
    && mysql_install_db --user=mysql --skip-name-resolve --rpm

COPY start-mysql stop-mysql /bin/

# Wrap your MySQL commands with start-mysql and stop-mysql
# Anything inside will have access to MySQL server
RUN start-mysql && \
    ./mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql mysql && \
    stop-mysql

EXPOSE 3306

CMD ["mysqld", "--user=mysql", "--skip-name-resolve", "--bind-address=0.0.0.0", "--pid-file=/var/run/mysqld/mysqld.pid", "--open-files-limit=5120"]