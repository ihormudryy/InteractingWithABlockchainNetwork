#!/bin/bash
set +xe

#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# Channel creation
export TLS_PATH=${CA_DIR}/peers/ordererOrganizations/${ORDERER_DOMAIN}/orderers/orderer.${ORDERER_DOMAIN}/msp/admincerts
echo "========== Creating channel: "$CHANNEL_NAME" in orderer.${ORDERER_DOMAIN}:7050 =========="
echo "---- using $ORDERER_CA cert ----"
peer channel create \
    -o orderer.${ORDERER_DOMAIN}:7050 \
    -c $CHANNEL_NAME \
    -f ${CA_DIR}/peers/${CHANNEL_NAME}.tx \
    --tls $CORE_PEER_TLS_ENABLED \
    --cafile ${TLS_PATH}/Admin@${ORDERER_DOMAIN}-cert.pem
    #\
    #--certfile ${TLS_PATH}/server.crt \
    #--keyfile ${TLS_PATH}/server.key
