function addOrg {
    echo "
        '${ORG}': {
            'name': '${PEER_NAME}',
            'mspid': '${ORG}MSP',
            'peer1': {
                'requests': 'grpcs://${PEER_HOST}:7051',
                'events': 'grpcs://${PEER_HOST}:7053',
                'server-hostname': '${PEER_HOST}',
                'tls_cacerts': '/$DATA/tls/$PEER_NAME-client.crt'
            },          
            'peer2': {
                'requests': 'grpcs://127.0.0.1:8051',
                'events': 'grpcs://127.0.0.1:8053',
                'server-hostname': 'peer1.org1.example.com',
                'tls_cacerts': '../fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt'
            },          
            'admin': {
                'key': '../fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore',
                'cert': '../fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts'
            }
        }
    "
}

function writeConfigJSON {
BEGINNING = "
   'host':'localhost',
   'port':'8080',
   'channel': '${CHANNELNAME}',
   'GOPATH':'${GOPATH}',
   'keyValueStore':'/tmp/fabric-client-kvs',
   'eventWaitTime':'30000',     
   'mysql':{
      'host':'127.0.0.1',
      'port':'3306',
      'database':'fabricexplorer',
      'username':'root',
      'passwd':'root'
   }
   'network-config': { 
"
for ORG in $addOrg; do
    initOrgVars $ORG
    addOrg
done

BEGINNING="${BEGINNING}}"