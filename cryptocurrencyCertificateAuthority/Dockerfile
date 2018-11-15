FROM docker.io/hyperledger/fabric-ca:amd64-1.3.0

RUN mkdir /ca
COPY fabric-ca-server-config.yaml /ca
COPY tls /ca/tls
COPY ca /ca/ca
