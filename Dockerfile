FROM ubuntu:14.04
MAINTAINER wuhx <i@xun.im>


RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

COPY ./sources.list.aliyun /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y python-pip python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev \
    curl libfreetype6 libfontconfig

#JRE http://download.oracle.com/otn-pub/java/jdk/8u74-b02/server-jre-8u74-linux-x64.tar.gz
#JDK http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-linux-x64.tar.gz
RUN DIR=/app/env/jdk; mkdir -p $DIR \
   && curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u74-b02/server-jre-8u74-linux-x64.tar.gz \
   | tar -xzC $DIR --strip-components 1
ENV PATH /app/env/jdk/bin:$PATH

#phantomjs
RUN DIR=/app/env/phantomjs; VERSION=2.1.1; mkdir -p $DIR \
   && curl -SL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$VERSION-linux-x86_64.tar.bz2 \
   | tar -xjC $DIR --strip-components 1 \
   && ln -s $DIR/bin/phantomjs /bin

#mitmproxy
RUN DIR=/app/env/mitmproxy; mkdir -p $DIR \
    && curl -L https://goo.gl/xSjI4R \
    | tar -xjC $DIR

#ivy
RUN DIR=/app/env/ivy; mkdir -p $DIR \
    && curl -L http://ftp.riken.jp/net/apache//ant/ivy/2.4.0/apache-ivy-2.4.0-bin-with-deps.tar.gz \
    | tar -xzC $DIR --strip-components 1
COPY ./ivy.xml /app/
RUN cd /app; \
    java -jar /app/env/ivy/ivy-*.jar \
     -ivy /app/ivy.xml \
     -retrieve "lib/[artifact].[ext]"

#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./resources/ /app/resources
COPY ./wx.jar /app/
COPY ./run.sh /app/

EXPOSE 10010

ENTRYPOINT ["/app/run.sh"]
