#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
export channel_name="marketplace_channel"
export orderer="HEREOrderer"
export orderer_domain="example.com"
export org1="Consumer"
export org2="Provider"
export org1_domain="consumer.example.com"
export org2_domain="provider.example.com"
export domain="localhost"

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="./chaincodes/go"
		;;
		"node")
		CC_SRC_PATH="./chaincodes/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "POST request Enroll on ${org1}  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d "username=Ihor&orgName=${org1}")
echo $ORG1_TOKEN
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "${org1} token is $ORG1_TOKEN"
echo
echo "POST request Enroll on ${org2} ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d "username=Barry&orgName=${org2}")
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "${org2} token is $ORG2_TOKEN"
echo
echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	"channelName":"${channel_name}",
	"channelConfigPath":"./cli/peers/channel.tx"
}"
echo
echo
sleep 5
echo "POST request Join channel on ${org1}"
echo
curl -s -X POST \
  http://localhost:4000/channels/${channel_name}/peers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.${org1_domain}\",\"peer1.${org1_domain}\"]
}"
echo
echo

echo "POST request Join channel on ${org2}"
echo
curl -s -X POST \
  http://localhost:4000/channels/${channel_name}/peers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.${org2_domain}\",\"peer1.${org2_domain}\"]
}"
echo
echo

echo "POST request Update anchor peers on ${org1}"
echo
curl -s -X POST \
  http://localhost:4000/channels/${channel_name}/anchorpeers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"configUpdatePath\":\"./cli/peers/${org1}MSPAnchors.tx\"
}"
echo
echo

echo "POST request Update anchor peers on ${org2}"
echo
curl -s -X POST \
  http://localhost:4000/channels/${channel_name}/anchorpeers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"configUpdatePath\":\"./cli/peers/${org2}MSPAnchors.tx\"
}"
echo
echo

echo "POST Install chaincode on ${org1}"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.${org1_domain}\",\"peer1.${org1_domain}\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on ${org2}"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.${org2_domain}\",\"peer1.${org2_domain}\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST instantiate chaincode on ${org1}"
echo
curl -s -X POST \
  http://localhost:4000/channels/${channel_name}/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"mycc\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"a\",\"100\",\"b\",\"200\"]
}"
echo
echo

echo "POST invoke chaincode on peers of ${org1} and ${org2}"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/${channel_name}/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.${org1_domain}\",\"peer0.${org2_domain}\"],
	\"fcn\":\"move\",
	\"args\":[\"a\",\"b\",\"10\"]
}")
echo "Transaction ID is $TRX_ID"
echo
echo

echo "GET query chaincode on peer1 of ${org1}"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${channel_name}/chaincodes/mycc?peer=peer0.${org1_domain}&fcn=query&args=%5B%22a%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Block by blockNumber"
echo
BLOCK_INFO=$(curl -s -X GET \
  "http://localhost:4000/channels/${channel_name}/blocks/1?peer=peer0.${org1_domain}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json")
echo $BLOCK_INFO
# Assign previvious block hash to HASH
HASH=$(echo $BLOCK_INFO | jq -r ".header.previous_hash")
echo

echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/${channel_name}/transactions/$TRX_ID?peer=peer0.${org1_domain} \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "GET query Block by Hash - Hash is $HASH"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${channel_name}/blocks?hash=$HASH&peer=peer0.${org1_domain}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "cache-control: no-cache" \
  -H "content-type: application/json" \
  -H "x-access-token: $ORG1_TOKEN"
echo
echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${channel_name}?peer=peer0.${org1_domain}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.${org1_domain}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${channel_name}/chaincodes?peer=peer0.${org1_domain}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.${org1_domain}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
