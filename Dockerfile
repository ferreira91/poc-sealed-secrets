FROM openjdk:16-alpine3.13

ENV MICRONAUT_CONFIG_FILES=/etc/config/secret/application.yaml

ARG PORT=8080
ARG JAR_FILE=./build/libs/*-all.jar

COPY ${JAR_FILE} app.jar

EXPOSE ${PORT}

ENTRYPOINT ["java", "-jar", "app.jar" ]