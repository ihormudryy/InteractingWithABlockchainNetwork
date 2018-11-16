#!/bin/bash
set -e

CHANNEL_NAME="mychannel"
PROJPATH=$(pwd)
CRYPTO_CONF="$PROJPATH/crypto-config"
CLIPATH=$CRYPTO_CONF/cli/peers
ORDERERS=$CLIPATH/ordererOrganizations
PEERS=$CLIPATH/peerOrganizations
export FABRIC_CFG_PATH="$CRYPTO_CONF"
if [[ $(uname) = 'Darwin' ]]; then
    PLATFORM="mac"
else
    PLATFORM="ubuntu"
fi

rm -rf $CLIPATH

echo
echo "#################################################################"
echo "#######        Generating cryptographic material       ##########"
echo "#################################################################"
$PROJPATH/generators/$PLATFORM/cryptogen generate --config=$CRYPTO_CONF/crypto-config.yaml --output=$CLIPATH

echo
echo "##########################################################"
echo "#########  Generating Orderer Genesis block ##############"
echo "##########################################################"
$PROJPATH/generators/$PLATFORM/configtxgen -profile TwoOrgsGenesis -outputBlock $CLIPATH/genesis.block

echo
echo "#################################################################"
echo "### Generating channel configuration transaction 'channel.tx' ###"
echo "#################################################################"
$PROJPATH/generators/$PLATFORM/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx $CLIPATH/channel.tx -channelID $CHANNEL_NAME
cp $CLIPATH/channel.tx $CRYPTO_CONF/configuration/channel.tx

echo
echo "#################################################################"
echo "#######    Generating anchor peer update for ShopOrg   ##########"
echo "#################################################################"
$PROJPATH/generators/$PLATFORM/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $CLIPATH/ShopOrgMSPAnchors.tx -channelID $CHANNEL_NAME -asOrg ShopOrgMSP

echo
echo "##################################################################"
echo "####### Generating anchor peer update for RepairShopOrg ##########"
echo "##################################################################"
$PROJPATH/generators/$PLATFORM/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $CLIPATH/CryptocurrencyOrgMSPAnchors.tx -channelID $CHANNEL_NAME -asOrg CryptocurrencyOrgMSP

rm -rf $CRYPTO_CONF/{orderer,shopPeer,cryptocurrencyPeer}
mkdir $CRYPTO_CONF/{orderer,shopPeer,cryptocurrencyPeer}
cp -r $ORDERERS/orderer-org/orderers/orderer0/{msp,tls} $CRYPTO_CONF/orderer
cp -r $PEERS/shop-org/peers/shop-peer/{msp,tls} $CRYPTO_CONF/shopPeer
cp -r $PEERS/cryptocurrency-org/peers/cryptocurrency-peer/{msp,tls} $CRYPTO_CONF/cryptocurrencyPeer
cp $CLIPATH/genesis.block $CRYPTO_CONF/orderer

SHOP_CA_PATH=$CRYPTO_CONF/shopCA/ca
COIN_NAME_CA_PATH=$CRYPTO_CONF/cryptocurrencyCA/ca

rm -rf {$SHOP_CA_PATH,${COIN_NAME_CA_PATH}}/{ca,tlsca,tls}
mkdir -p {$SHOP_CA_PATH,${COIN_NAME_CA_PATH}}/{ca,tlsca,tls}

cp -r $PEERS/shop-org/ca/* $SHOP_CA_PATH/ca
cp -r $PEERS/shop-org/tlsca/* $SHOP_CA_PATH/tls
mv $SHOP_CA_PATH/ca/*_sk $SHOP_CA_PATH/ca/key.pem
mv $SHOP_CA_PATH/ca/*-cert.pem $SHOP_CA_PATH/ca/cert.pem
mv $SHOP_CA_PATH/tls/*_sk $SHOP_CA_PATH/tls/key.pem
mv $SHOP_CA_PATH/tls/*-cert.pem $SHOP_CA_PATH/tls/cert.pem
cp -r $CRYPTO_CONF/configuration/fabric-ca-server-configs/shop/*.yaml ${SHOP_CA_PATH}/../
rm -rf $SHOP_CA_PATH/tlsca

cp -r $PEERS/cryptocurrency-org/ca/* ${COIN_NAME_CA_PATH}/ca
cp -r $PEERS/cryptocurrency-org/tlsca/* ${COIN_NAME_CA_PATH}/tls
mv ${COIN_NAME_CA_PATH}/ca/*_sk ${COIN_NAME_CA_PATH}/ca/key.pem
mv ${COIN_NAME_CA_PATH}/ca/*-cert.pem ${COIN_NAME_CA_PATH}/ca/cert.pem
mv ${COIN_NAME_CA_PATH}/tls/*_sk ${COIN_NAME_CA_PATH}/tls/key.pem
mv ${COIN_NAME_CA_PATH}/tls/*-cert.pem ${COIN_NAME_CA_PATH}/tls/cert.pem
cp -r $CRYPTO_CONF/configuration/fabric-ca-server-configs/cryptocurrency/*.yaml ${COIN_NAME_CA_PATH}/../
rm -rf $COIN_NAME_CA_PATH/tlsca

WEBCERTS=$CRYPTO_CONF/configuration/certs
rm -rf $WEBCERTS
mkdir -p $WEBCERTS
cp $CRYPTO_CONF/orderer/tls/ca.crt $WEBCERTS/ordererOrg.pem
cp $CRYPTO_CONF/shopPeer/tls/ca.crt $WEBCERTS/shopOrg.pem
cp $CRYPTO_CONF/cryptocurrencyPeer/tls/ca.crt $WEBCERTS/cryptocurrencyOrg.pem
cp $PEERS/shop-org/users/Admin@shop-org/msp/keystore/* $WEBCERTS/Admin@shop-org-key.pem
cp $PEERS/shop-org/users/Admin@shop-org/msp/signcerts/* $WEBCERTS/
cp $PEERS/cryptocurrency-org/users/Admin@cryptocurrency-org/msp/keystore/* $WEBCERTS/Admin@cryptocurrency-org-key.pem
cp $PEERS/cryptocurrency-org/users/Admin@cryptocurrency-org/msp/signcerts/* $WEBCERTS/

WEBCERTS=$PROJPATH/blockchainNetwork

BACKEND=$PROJPATH/backend
rm -rf $BACKEND/set-up
mkdir -p $BACKEND/set-up
cp -r $WEBCERTS/set-up/* $BACKEND/set-up/

cd $CRYPTO_CONF/configuration
npm install
node config.js
cd $PROJPATH
rm -rf $CRYPTO_CONF/cli
