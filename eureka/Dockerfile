FROM maven:3.9.6-amazoncorretto-17 AS build
COPY . .
RUN mvn clean package

# Use OpenJDK for running the application
FROM openjdk:17-jdk-slim
COPY --from=build /target/*.jar /eureka-server.jar
EXPOSE 8761
ENTRYPOINT ["java","-jar","/eureka-server.jar"]