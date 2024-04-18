docker build --build-arg MODULE_DIR=eureka --build-arg PORT=8761 -t gcr.io/plantcare-420709/eureka-server:latest .
docker push gcr.io/plantcare-420709/eureka-server:latest