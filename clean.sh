#!/bin/bash

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
