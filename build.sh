#!/bin/bash
export FABRIC_CFG_PATH=$PWD
export COIN_NAME="mudryycoin"
export COIN_NAME_CAMELCASE="MudryyCoin"

bash ./clean.sh
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
