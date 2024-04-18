FROM maven:3.9.6-amazoncorretto-17 AS build
WORKDIR /build

COPY . .

ARG MODULE_DIR
RUN mvn -f /build/${MODULE_DIR}/pom.xml clean package -DskipTests=true

# Use OpenJDK for running the application
FROM openjdk:17-jdk-slim
ARG MODULE_DIR
ARG PORT
COPY --from=build /build/${MODULE_DIR}/target/*.jar app.jar
EXPOSE ${PORT}
ENTRYPOINT ["java","-jar","app.jar"]