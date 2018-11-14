#!/bin/sh
set -e

echo
echo "#################################################################"
echo "#######        Generating cryptographic material       ##########"
echo "#################################################################"
PROJPATH=$(pwd)
CLIPATH=$PROJPATH/cli/peers
ORDERERS=$CLIPATH/ordererOrganizations
PEERS=$CLIPATH/peerOrganizations

rm -rf $CLIPATH
$PROJPATH/cryptogen generate --config=$PROJPATH/crypto-config.yaml --output=$CLIPATH

sh generate-cfgtx.sh

rm -rf $PROJPATH/{orderer,shopPeer,${COIN_NAME}Peer}/crypto
mkdir $PROJPATH/{orderer,shopPeer,${COIN_NAME}Peer}/crypto
cp -r $ORDERERS/orderer-org/orderers/orderer0/{msp,tls} $PROJPATH/orderer/crypto
cp -r $PEERS/shop-org/peers/shop-peer/{msp,tls} $PROJPATH/shopPeer/crypto
cp -r $PEERS/${COIN_NAME}-org/peers/${COIN_NAME}-peer/{msp,tls} $PROJPATH/${COIN_NAME}Peer/crypto
cp $CLIPATH/genesis.block $PROJPATH/orderer/crypto/

SHOPCAPATH=$PROJPATH/shopCertificateAuthority
COIN_NAMECAPATH=$PROJPATH/${COIN_NAME}CertificateAuthority

rm -rf {$SHOPCAPATH,${COIN_NAME}CAPATH}/{ca,tls}
mkdir -p {$SHOPCAPATH,${COIN_NAME}CAPATH}/{ca,tls}

cp $PEERS/shop-org/ca/* $SHOPCAPATH/ca
cp $PEERS/shop-org/tlsca/* $SHOPCAPATH/tls
mv $SHOPCAPATH/ca/*_sk $SHOPCAPATH/ca/key.pem
mv $SHOPCAPATH/ca/*-cert.pem $SHOPCAPATH/ca/cert.pem
mv $SHOPCAPATH/tls/*_sk $SHOPCAPATH/tls/key.pem
mv $SHOPCAPATH/tls/*-cert.pem $SHOPCAPATH/tls/cert.pem

cp $PEERS/${COIN_NAME}-org/ca/* ${COIN_NAME}CAPATH/ca
cp $PEERS/${COIN_NAME}-org/tlsca/* ${COIN_NAME}CAPATH/tls
mv ${COIN_NAME}CAPATH/ca/*_sk ${COIN_NAME}CAPATH/ca/key.pem
mv ${COIN_NAME}CAPATH/ca/*-cert.pem ${COIN_NAME}CAPATH/ca/cert.pem
mv ${COIN_NAME}CAPATH/tls/*_sk ${COIN_NAME}CAPATH/tls/key.pem
mv ${COIN_NAME}CAPATH/tls/*-cert.pem ${COIN_NAME}CAPATH/tls/cert.pem

WEBCERTS=$PROJPATH/configuration/certs
rm -rf $WEBCERTS
mkdir -p $WEBCERTS
cp $PROJPATH/orderer/crypto/tls/ca.crt $WEBCERTS/ordererOrg.pem
cp $PROJPATH/shopPeer/crypto/tls/ca.crt $WEBCERTS/shopOrg.pem
cp $PROJPATH/${COIN_NAME}Peer/crypto/tls/ca.crt $WEBCERTS/${COIN_NAME}Org.pem
cp $PEERS/shop-org/users/Admin@shop-org/msp/keystore/* $WEBCERTS/Admin@shop-org-key.pem
cp $PEERS/shop-org/users/Admin@shop-org/msp/signcerts/* $WEBCERTS/
cp $PEERS/${COIN_NAME}-org/users/Admin@${COIN_NAME}-org/msp/keystore/* $WEBCERTS/Admin@${COIN_NAME}-org-key.pem
cp $PEERS/${COIN_NAME}-org/users/Admin@${COIN_NAME}-org/msp/signcerts/* $WEBCERTS/

WEBCERTS=$PROJPATH/blockchainNetwork

BACKEND=$PROJPATH/backend
rm -rf $BACKEND/set-up
mkdir -p $BACKEND/set-up
cp -r $WEBCERTS/set-up/* $BACKEND/set-up/

rm -rf $CLIPATH

cd configuration
npm install
node config.js
cd ..
