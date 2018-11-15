#!/bin/sh

CHANNEL_NAME="mychannel"
PROJPATH=$(pwd)
CLIPATH=$PROJPATH/cli/peers
PLATFORM=""

if [[ $(uname) = 'Darwin' ]]; then
    PLATFORM="mac"
else
    PLATFORM="ubuntu"
fi

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
cp $CLIPATH/channel.tx $PROJPATH/configuration/channel.tx

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