#!/bin/bash
export FABRIC_CFG_PATH=$PWD
export COIN_NAME="mudryycoin"
export COIN_NAME_CAMELCASE="MudryyCoin"
export DB_ADMIN=""
export DB_PASSWORD=""
export RABBITMQ_USER="guest"
export RABBITMQ_PASS="guest"
export CA_TAG="amd64-1.3.0"
export FABRIC_TAG="amd64-0.4.14"

clean(){
    docker rm -f $(docker ps -aq)
    images=(blockchain-setup cryptocurrency-ca shop-ca orderer-peer cryptocurrency-peer shop-peer backend redis-server rabbit-client)
    for i in "${images[@]}"
    do
        echo Removing image : $i
        docker rmi -f $i
    done

    #docker rmi -f $(docker images | grep none)
    images=(dev-shop-peer dev-cryptocurrency-peer)
    for i in "${images[@]}"
    do
        echo Removing image : $i
        docker rmi -f $(docker images | grep $i )
    done

    docker rmi $(docker images -f "dangling=true" -q)
}

clean

bash ./generate-certs.sh
bash ./docker-images.sh

docker-compose -p "${COIN_NAME}" up -d cryptocurrency-peer
sleep 20s
docker-compose -p "${COIN_NAME}" up -d blockchain-setup
sleep 30s
docker-compose -p "${COIN_NAME}" up -d rabbitmq
sleep 50s
docker exec rabbitmq1 /bin/sh -c "rabbitmqctl set_policy ha-all '.' \"{'ha-mode':'all','ha-sync-mode':'automatic'}\""
sleep 10s
docker-compose -p "${COIN_NAME}" up -d
sleep 1s
docker-compose -p "${COIN_NAME}" up -d --scale ${COIN_NAME}-backend=2
sleep 1s
docker-compose -p "${COIN_NAME}" up -d --scale ${COIN_NAME}-backend=3
sleep 1s
docker-compose -p "${COIN_NAME}" up -d --scale ${COIN_NAME}-backend=4
sleep 1s
docker-compose -p "${COIN_NAME}" up -d --scale ${COIN_NAME}-backend=5
sleep 1s
docker ps

containers=$(docker ps -a --format "{{.Names}}")
rm -rf ./Docker_Container_Logs && mkdir ./Docker_Container_Logs
for CONTAINER in ${containers[*]}; do
    docker logs $CONTAINER &> ./Docker_Container_Logs/$CONTAINER.log
done
echo "Logs can be found in Docker_Container_Logs dir"