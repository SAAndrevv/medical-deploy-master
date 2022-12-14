#!/bin/bash

function build_basic_images() {
  JAR_FILE=$1
  APP_NAME=$2

  docker build -f ./build-scripts/docker/basic/Dockerfile \
    --build-arg JAR_FILE=${JAR_FILE} \
    -t ${APP_NAME}:latest \
    -t ${APP_NAME}:simple .
}

function up_docker_container() {
  docker-compose -f ./build-scripts/compose/simple/docker-compose.yml up
}

function build_jar() {
  # Get count of args
for var in $@
  do
    DIR=$var
    echo "Building JAR files for ${DIR}"
    CD_PATH="./${DIR}"
    cd ${CD_PATH}
    mvn clean package -T 3 -DskipTests
    cd ..
  done
}

function build_lib() {
  # Get count of args
for var in $@
  do
    DIR=$var
    echo "Building JAR files for ${DIR}"
    CD_PATH="./${DIR}"
    cd ${CD_PATH}
    mvn clean install -T 3 -DskipTests
    cd ..
  done
}

function pull_or_clone_proj() {
  SERVICE_NAME=$1
  SERVICE_URL=$2
 if cd ${SERVICE_NAME}
  then
 #  git branch -f master origin/master
<<<<<<< HEAD
   git checkout dev
   git pull
   cd ..
  else
    git clone --branch dev ${SERVICE_URL} ${SERVICE_NAME}
=======
   git checkout develop
   git pull
   cd ..
  else
    git clone --branch develop ${SERVICE_URL} ${SERVICE_NAME}
>>>>>>> hometask-5
 fi
}

# Building the app
cd ..

# Clone or update projects
pull_or_clone_proj common-module https://github.com/SAAndrevv/common-module.git
pull_or_clone_proj medical-monitoring https://github.com/SAAndrevv/medical-monitoring.git
pull_or_clone_proj message-analyzer https://github.com/SAAndrevv/message-analyzer.git
pull_or_clone_proj person-service https://github.com/SAAndrevv/person-service.git
pull_or_clone_proj queue-reader https://github.com/SAAndrevv/queue-reader.git

build_lib common-module
build_jar medical-monitoring message-analyzer person-service queue-reader

APP_VERSION=0.0.1-SNAPSHOT

echo "Building Docker images"
build_basic_images ./medical-monitoring/core/target/medical-monitoring-${APP_VERSION}.jar application/medical-monitoring
build_basic_images ./message-analyzer/core/target/message-analyzer-${APP_VERSION}.jar application/message-analyzer
build_basic_images ./person-service/core/target/person-service-${APP_VERSION}.jar application/person-service
build_basic_images ./queue-reader/core/target/queue-reader-${APP_VERSION}.jar application/queue-reader

echo "Docker container up"
up_docker_container