#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

run(){
  peer chaincode install -n $NAME -v 1.0 -p /opt/gopath/src/github.com/hyperledger/fabric/peer/all/chaincode/marketplace/ -l node
}

echo "========== Installing chaincode on peer0.org1 =========="
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
#peer chaincode install -n $CC_NAME -v $1 -p github.com/hyperledger/fabric/examples/chaincode/go
#peer chaincode install -n $NAME -v 1.0 -p /opt/gopath/src/github.com/hyperledger/fabric/peer/all/chaincode/marketplace/ -l node
run

echo "========== Installing chaincode on peer1.org1 =========="
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer1.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
#peer chaincode install -n $CC_NAME -v $1 -p github.com/hyperledger/fabric/examples/chaincode/go
#peer chaincode install -n $e -v 1.0 -p /opt/gopath/src/github.com/hyperledger/fabric/peer/all/chaincode/marketplace/ -l node
run

echo "========== Installing chaincode on peer0.org2 =========="
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
#peer chaincode install -n $CC_NAME -v $1 -p github.com/hyperledger/fabric/examples/chaincode/go
#peer chaincode install -n marketplace -v 1.0 -p /opt/gopath/src/github.com/hyperledger/fabric/peer/all/chaincode/marketplace/ -l node
run

echo "========== Installing chaincode on peer1.org2 =========="
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer1.org2.example.com:7051
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
#peer chaincode install -n $CC_NAME -v $1 -p github.com/hyperledger/fabric/examples/chaincode/go
#peer chaincode install -n marketplace -v 1.0 -p /opt/gopath/src/github.com/hyperledger/fabric/peer/all/chaincode/marketplace/ -l node
run
