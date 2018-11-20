
docker stop blockchain-setup
docker rm blockchain-setup
docker run -it \
-e "DOCKER_SOCKET_PATH=/host/var/run/docker.sock" \
-e "DOCKER_CCENV_IMAGE=hyperledger/fabric-ccenv" \
-e "SECRETSDIR=/run/secrets" \
--name blockchain-setup \
-v $(pwd)/crypto-config/configuration/config.json:/run/secrets/config \
-v $(pwd)/crypto-config/configuration/channel.tx:/run/secrets/channel \
-v /var/run/:/host/var/run/ \
blockchain-setup