FROM alpine:3.12

MAINTAINER Dilshan Fernando<dilshan.fdo@gmail.com>

ARG JMETER_VERSION="5.3"
#ARG JMETER_PLUGINS="jpgc-ffw=2.0"
ARG JMETER_PLUGINS=""
ARG TZ=UTC

ENV JMETER_PLUGIN_MANAGER="1.4"
ENV JMETER_REPOSITORY_URL="https://repo1.maven.org/maven2/kg/apc"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_PLUGIN_MANAGER_URL ${JMETER_REPOSITORY_URL}/jmeter-plugins-manager/${JMETER_PLUGIN_MANAGER}/jmeter-plugins-manager-${JMETER_PLUGIN_MANAGER}.jar
ENV JMETER_CMDRUNNER_URL ${JMETER_REPOSITORY_URL}/cmdrunner/2.2/cmdrunner-2.2.jar
ENV JAVA_JDK_VERSION="11"

# Download JMeter and extra packages
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk${JAVA_JDK_VERSION}-jdk tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt

# Download JMeter Plugins only IF user pass any
RUN 	if [ "$JMETER_PLUGINS" != "" ] ; then \
       curl --silent ${JMETER_CMDRUNNER_URL} >  /tmp/dependencies/cmdrunner-2.2.jar  \
    && mv /tmp/dependencies/cmdrunner-2.2.jar  ${JMETER_HOME}/lib  \
	&& curl --silent ${JMETER_PLUGIN_MANAGER_URL} >  /tmp/dependencies/jmeter-plugins-manager-${JMETER_PLUGIN_MANAGER}.jar  \
	&& mv /tmp/dependencies/jmeter-plugins-manager-${JMETER_PLUGIN_MANAGER}.jar  /${JMETER_HOME}/lib/ext  \
	&& java -cp ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PLUGIN_MANAGER}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller  \
	&& ${JMETER_BIN}/PluginsManagerCMD.sh install ${JMETER_PLUGINS} ; fi\
	&& rm -rf /tmp/dependencies

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Entrypoint has same signature as "jmeter" command
COPY docker-entrypoint.sh /

WORKDIR	${JMETER_HOME}

# Copy the performance enhanced property files
#https://www.xtivia.com/fixing-jmeter-socket-errors/
COPY jmeter.properties ${JMETER_HOME}/bin
COPY hc.parameters ${JMETER_HOME}/bin

ENTRYPOINT ["/docker-entrypoint.sh"]


