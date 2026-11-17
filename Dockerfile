FROM eclipse-temurin:21-jdk-alpine

RUN adduser -D -u 10001 nonroot
USER nonroot

COPY target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]