#!/bin/sh

CHANNEL_NAME="mychannel"
PROJPATH=$(pwd)
CLIPATH=$PROJPATH/cli/peers

echo
echo "##########################################################"
echo "#########  Generating Orderer Genesis block ##############"
echo "##########################################################"
$PROJPATH/ubuntu/configtxgen -profile TwoOrgsGenesis -outputBlock $CLIPATH/genesis.block

echo
echo "#################################################################"
echo "### Generating channel configuration transaction 'channel.tx' ###"
echo "#################################################################"
$PROJPATH/ubuntu/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx $CLIPATH/channel.tx -channelID $CHANNEL_NAME
cp $CLIPATH/channel.tx $PROJPATH/configuration/channel.tx

echo
echo "#################################################################"
echo "#######    Generating anchor peer update for ShopOrg   ##########"
echo "#################################################################"
$PROJPATH/ubuntu/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $CLIPATH/ShopOrgMSPAnchors.tx -channelID $CHANNEL_NAME -asOrg ShopOrgMSP

echo
echo "##################################################################"
echo "####### Generating anchor peer update for RepairShopOrg ##########"
echo "##################################################################"
$PROJPATH/ubuntu/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $CLIPATH/CryptocurrencyOrgMSPAnchors.tx -channelID $CHANNEL_NAME -asOrg CryptocurrencyOrgMSP