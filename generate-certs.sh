#!/bin/bash
set -e

echo
echo "#################################################################"
echo "#######        Generating cryptographic material       ##########"
echo "#################################################################"
PROJPATH=$(pwd)
CLIPATH=$PROJPATH/cli/peers
ORDERERS=$CLIPATH/ordererOrganizations
PEERS=$CLIPATH/peerOrganizations

if [[ $(uname) = 'Darwin' ]]; then
    PLATFORM="mac"
else
    PLATFORM="ubuntu"
fi

rm -rf $CLIPATH
$PROJPATH/generators/$PLATFORM/cryptogen generate --config=$PROJPATH/crypto-config.yaml --output=$CLIPATH

sh generate-cfgtx.sh

rm -rf $PROJPATH/{orderer,shopPeer,cryptocurrencyPeer}/crypto
mkdir $PROJPATH/{orderer,shopPeer,cryptocurrencyPeer}/crypto
cp -r $ORDERERS/orderer-org/orderers/orderer0/{msp,tls} $PROJPATH/orderer/crypto
cp -r $PEERS/shop-org/peers/shop-peer/{msp,tls} $PROJPATH/shopPeer/crypto
cp -r $PEERS/cryptocurrency-org/peers/cryptocurrency-peer/{msp,tls} $PROJPATH/cryptocurrencyPeer/crypto
cp $CLIPATH/genesis.block $PROJPATH/orderer/crypto/

SHOPCAPATH=$PROJPATH/shopCertificateAuthority
COIN_NAME_CA_PATH=$PROJPATH/cryptocurrencyCertificateAuthority

rm -rf {$SHOPCAPATH,${COIN_NAME_CA_PATH}}/{ca,tlsca}
mkdir -p {$SHOPCAPATH,${COIN_NAME_CA_PATH}}/{ca,tlsca}

cp $PEERS/shop-org/ca/* $SHOPCAPATH/ca
cp $PEERS/shop-org/tlsca/* $SHOPCAPATH/tls
mv $SHOPCAPATH/ca/*_sk $SHOPCAPATH/ca/key.pem
mv $SHOPCAPATH/ca/*-cert.pem $SHOPCAPATH/ca/cert.pem
mv $SHOPCAPATH/tls/*_sk $SHOPCAPATH/tls/key.pem
mv $SHOPCAPATH/tls/*-cert.pem $SHOPCAPATH/tls/cert.pem

cp $PEERS/cryptocurrency-org/ca/* ${COIN_NAME_CA_PATH}/ca
cp $PEERS/cryptocurrency-org/tlsca/* ${COIN_NAME_CA_PATH}/tls
mv ${COIN_NAME_CA_PATH}/ca/*_sk ${COIN_NAME_CA_PATH}/ca/key.pem
mv ${COIN_NAME_CA_PATH}/ca/*-cert.pem ${COIN_NAME_CA_PATH}/ca/cert.pem
mv ${COIN_NAME_CA_PATH}/tls/*_sk ${COIN_NAME_CA_PATH}/tls/key.pem
mv ${COIN_NAME_CA_PATH}/tls/*-cert.pem ${COIN_NAME_CA_PATH}/tls/cert.pem

WEBCERTS=$PROJPATH/configuration/certs
rm -rf $WEBCERTS
mkdir -p $WEBCERTS
cp $PROJPATH/orderer/crypto/tls/ca.crt $WEBCERTS/ordererOrg.pem
cp $PROJPATH/shopPeer/crypto/tls/ca.crt $WEBCERTS/shopOrg.pem
cp $PROJPATH/cryptocurrencyPeer/crypto/tls/ca.crt $WEBCERTS/cryptocurrencyOrg.pem
cp $PEERS/shop-org/users/Admin@shop-org/msp/keystore/* $WEBCERTS/Admin@shop-org-key.pem
cp $PEERS/shop-org/users/Admin@shop-org/msp/signcerts/* $WEBCERTS/
cp $PEERS/cryptocurrency-org/users/Admin@cryptocurrency-org/msp/keystore/* $WEBCERTS/Admin@cryptocurrency-org-key.pem
cp $PEERS/cryptocurrency-org/users/Admin@cryptocurrency-org/msp/signcerts/* $WEBCERTS/

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
