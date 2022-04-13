DOCKER_HUB_USERNAME="zakiraihan"
DOCKER_COMPOSE_PATH=$(pwd)

echo "On Process: Creating Docker Image"
docker build -f $DOCKER_COMPOSE_PATH/content-init/Dockerfile -t $DOCKER_HUB_USERNAME/neuro-init $DOCKER_COMPOSE_PATH/content-init
docker build -f $DOCKER_COMPOSE_PATH/content-api/Dockerfile -t $DOCKER_HUB_USERNAME/neuro-api $DOCKER_COMPOSE_PATH/content-api
docker build -f $DOCKER_COMPOSE_PATH/content-web/Dockerfile -t $DOCKER_HUB_USERNAME/neuro-web $DOCKER_COMPOSE_PATH/content-web
echo "Done: Creating Docker Image"

echo "On Process: Pushing Docker Image"
docker push $DOCKER_HUB_USERNAME/neuro-init
docker push $DOCKER_HUB_USERNAME/neuro-api
docker push $DOCKER_HUB_USERNAME/neuro-web
echo "Done: Pushing Docker Image"

echo "On Process: Create Docker Network for Service"
docker network create --driver bridge neuro_default;
echo "Done: Create Docker Network for Service"

echo "On Process: Create Docker Container for MongoDB"
docker run -d \
    -p 27017:27017 \
    --network neuro_default \
    --name neuro-db \
    --mount type=bind,src=/Users/ecomindo/Work/Labs/Docker/EcomindoWorkshop/Sesi3/mongodb-data,dst=/data/db \
    mongo:latest;
echo "Done: Create Docker Container for MongoDB"

echo "On Process: Initialize data for MongoDB"
docker run --rm --name neuro-init-db \
    --network neuro_default \
    -e MONGODB_CONNECTION=mongodb://neuro-db:27017/contentdb \
    zakiraihan/neuro-init;
echo "Done: Initialize data for MongoDB"

echo "On Process: Create Docker Container for Web Api"
docker run -d --name neuro-api \
    --network neuro_default \
    -e MONGODB_CONNECTION=mongodb://neuro-db:27017/contentdb \
    zakiraihan/neuro-api;
echo "Done: Create Docker Container for Web Api"

echo "On Process: Create Docker Container for Web App"
docker run -d --name neuro-web \
    -p 3000:3000 \
    --network neuro_default \
    -e CONTENT_API_URL=http://neuro-api:3001 \
    zakiraihan/neuro-web;
echo "Done: Create Docker Container for Web App"