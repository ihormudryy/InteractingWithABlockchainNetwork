#!/bin/bash

docker rm -f $(docker ps -aq)
images=(blockchain-setup ${COIN_NAME}-ca shop-ca orderer-peer ${COIN_NAME}-peer shop-peer backend redis-server rabbit-client)
for i in "${images[@]}"
do
	echo Removing image : $i
  docker rmi -f $i
done

#docker rmi -f $(docker images | grep none)
images=( dev-shop-peer dev-${COIN_NAME}-peer)
for i in "${images[@]}"
do
	echo Removing image : $i
  docker rmi -f $(docker images | grep $i )
done

docker rmi $(docker images -f "dangling=true" -q)
