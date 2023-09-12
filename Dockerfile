FROM maven:3.8.1-openjdk-17-slim AS build
WORKDIR /app/src
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package

# Download and extract Apache Tomcat
FROM alpine:latest AS tomcat-download
WORKDIR /opt/
RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz && \
    tar xf apache-tomcat-9.0.80.tar.gz && \
    rm apache-tomcat-9.0.80.tar.gz


# Stage 2 - Create the final Docker image
FROM openjdk:17-slim
WORKDIR /app
COPY --from=tomcat-download /opt/apache-tomcat-9.0.80 /opt/apache-tomcat-9.0.80
COPY --from=build /app/src/target/online-banking.war /opt/apache-tomcat-9.0.80/webapps


EXPOSE 8080
ENTRYPOINT ["/opt/apache-tomcat-9.0.80/bin/catalina.sh", "run"]