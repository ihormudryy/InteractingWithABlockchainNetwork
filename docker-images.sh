#!/bin/bash
set -eu

dockerFabricPull() {
  local FABRIC_TAG=$1
  for IMAGES in peer orderer ccenv; do
      echo "==> FABRIC IMAGE: $IMAGES"
      echo
      docker pull hyperledger/fabric-$IMAGES:$FABRIC_TAG
      docker tag hyperledger/fabric-$IMAGES:$FABRIC_TAG hyperledger/fabric-$IMAGES
  done
}

dockerCaPull() {
      local CA_TAG=$1
      echo "==> FABRIC CA IMAGE"
      echo
      docker pull hyperledger/fabric-ca:$CA_TAG
      docker tag hyperledger/fabric-ca:$CA_TAG hyperledger/fabric-ca
}

BUILD=
DOWNLOAD=
if [ $# -eq 0 ]; then
    BUILD=true
    PUSH=true
    DOWNLOAD=true
else
    for arg in "$@"
        do
            if [ $arg == "build" ]; then
                BUILD=true
            fi
            if [ $arg == "download" ]; then
                DOWNLOAD=true
            fi
    done
fi

if [ $BUILD ];
    then
    echo '############################################################'
    echo '#                 BUILDING CONTAINER IMAGES                #'
    echo '############################################################'
    cp -r blockchainNetwork/set-up backend/
    docker build -t blockchain-setup:latest blockchainNetwork/
    docker build -t redis-server:latest redisCluster/
    docker build -t backend:latest backend/
    rm -rf backend/set-up
fi

if [ $DOWNLOAD ]; then
    echo "===> Pulling fabric Images"
    dockerFabricPull ${FABRIC_TAG}

    echo "===> Pulling fabric ca Image"
    dockerCaPull ${CA_TAG}

    docker pull hyperledger/fabric-couchdb:amd64-0.4.14
    echo
    echo "===> List out hyperledger docker images"
    docker images | grep hyperledger*
fi