#!/bin/bash
export FABRIC_CFG_PATH=$PWD
export COIN_NAME="herecoin"
export COIN_NAME_CAMELCASE="HERECoin"
export ADMIN="admin"
export ADMIN_PWD="adminpw"
export DB_ADMIN=""
export DB_PASSWORD=""
export RABBITMQ_USER="guest"
export RABBITMQ_PASS="guest"
export CA_TAG="amd64-1.3.0"
export FABRIC_TAG="amd64-0.4.14"

export channel_name="marketplace_channel"
export orderer="HEREOrderer"
export orderer_domain="example.com"
export org1="Consumer"
export org2="Provider"
export org1_domain="consumer.example.com"
export org2_domain="provider.example.com"
export domain="localhost"

clean() {
    #docker stop $(docker ps -a --format "{{.Names}}")
    docker rm -f $(docker ps -a --format "{{.Names}}")
    #docker rmi -f $(docker images)
}

build() {
    echo '############################################################'
    echo '#                 BUILDING CONTAINER IMAGES                #'
    echo '############################################################'
    mkdir -p blockchain/cli && cp -r ./templates/cli/* blockchain/cli
    docker build -t blockchain-setup:latest blockchain
    rm -rf blockchain/cli
}

eval "cat <<EOF
$(<templates/docker-compose_in.yaml)
EOF
" > docker-compose.yaml

eval "cat <<EOF
$(<templates/network-config_in.yaml)
EOF
" > blockchain/network-config.yaml

bash ./generate-certs.sh
clean
build
docker-compose up -d

containers=$(docker ps -a --format "{{.Names}}")
rm -rf ./Docker_Container_Logs && mkdir ./Docker_Container_Logs
for CONTAINER in ${containers[*]}; do
    docker logs $CONTAINER &> ./Docker_Container_Logs/$CONTAINER.log
done
echo "Logs can be found in Docker_Container_Logs dir"