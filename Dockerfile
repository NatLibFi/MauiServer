FROM maven:slim as builder

LABEL maintainer="Juho Inkinen <juho.inkinen@helsinki.fi>"


COPY src/ src/
COPY pom.xml .
RUN mvn package


FROM tomcat:8.5.59-jdk11-openjdk-slim

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libvoikko1=4.2-1 \
		voikko-fi=2.2-1.1 \
		gosu \
	&& rm -rf /var/lib/apt/lists/* /usr/include/*

COPY --from=builder /target/mauiserver-*-SNAPSHOT.war /usr/local/tomcat/webapps/mauiserver.war

COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME /mauidata
ENV MAUI_SERVER_DATA_DIR=/mauidata

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
