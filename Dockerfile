FROM openjdk:8 as builder
RUN echo 1
RUN apt-get update && apt-get install  -y curl
RUN curl -o /usr/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
RUN chmod +x /usr/bin/lein
COPY . /example-webapp
WORKDIR /example-webapp
RUN lein uberjar

FROM java:8-alpine
MAINTAINER Your Name <you@example.com>
COPY --from=builder /example-webapp/target/uberjar/example-webapp.jar /example-webapp/app.jar
EXPOSE 3000
CMD ["java", "-jar", "/example-webapp/app.jar"]
