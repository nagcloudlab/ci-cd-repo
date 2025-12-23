FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy JAR from transfer-service/target/
COPY transfer-service/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
