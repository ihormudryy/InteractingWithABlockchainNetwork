import yaml
import io

m_orderer = "HEREOrderer"

base = {
  "version": "3.1",
  "services": {}
}

orderer = {
  "container_name": "${orderer}",
  "image": "hyperledger/fabric-orderer:${IMAGE_TAG}",
  "environment": [
    "ORDERER_GENERAL_LOGLEVEL=INFO",
    "ORDERER_GENERAL_LISTENADDRESS=0.0.0.0",
    "ORDERER_GENERAL_GENESISMETHOD=file",
    "ORDERER_GENERAL_GENESISFILE=/etc/hyperledger/configtx/genesis.block",
    "ORDERER_GENERAL_LOCALMSPID=${orderer}MSP",
    "ORDERER_GENERAL_LOCALMSPDIR=/etc/hyperledger/configtx/msp",
    "ORDERER_GENERAL_TLS_ENABLED=true",
    "ORDERER_GENERAL_TLS_PRIVATEKEY=/etc/hyperledger/configtx/tls/server.key",
    "ORDERER_GENERAL_TLS_CERTIFICATE=/etc/hyperledger/configtx/tls/server.crt",
    "ORDERER_GENERAL_TLS_ROOTCAS=/etc/hyperledger/configtx/tls/ca.crt",
  ],
  "working_dir": "/etc/hyperledger/fabric/orderer",
  "command": "orderer",
  "volumes": [
    "${orderer}:/etc/hyperledger/configtx"
  ],
  "ports": [
    "7050:7050"
  ],
  "restart": "unless-stopped",
  "logging": {
    "driver": '"json-file"',
    "options": {
      "max-size": '"1m"',
      "max-file": '"10"'
    }
  }
}

peer_base = {
  "peer${num}.${org_domain}": {
    "container_name": "peer${num}.${org_domain}",
    "environment": [
      "CORE_LEDGER_STATE_STATEDATABASE=CouchDB",
      "CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=${DB_ADMIN}",
      "CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=${DB_PASSWORD}",
      "CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock",
      "CORE_LOGGING_LEVEL=INFO",
      "CORE_PEER_TLS_ENABLED=true",
      "CORE_PEER_ENDORSER_ENABLED=true",
      "CORE_PEER_GOSSIP_USELEADERELECTION=true",
      "CORE_PEER_GOSSIP_ORGLEADER=false",
      "CORE_PEER_PROFILE_ENABLED=true",
      "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/configtx/msp",
      "CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/configtx/tls/server.crt",
      "CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/configtx/tls/server.key",
      "CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/configtx/tls/ca.crt",
      "CORE_PEER_ID=peer${num}.${org_domain}",
      "CORE_PEER_ADDRESS=peer${num}.${org_domain}:7051",
      "CORE_PEER_GOSSIP_BOOTSTRAP=peer${num}.${org_domain}:7051",
      "CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer${num}.${org_domain}:7051",
      "CORE_PEER_LOCALMSPID=${org_domain}MSP"
    ],
    "volumes": [
        "/var/run/:/host/var/run/",
        "./templates/cli/${org_domain}/peers/peer${num}.${org_domain}/msp:/etc/hyperledger/fabric/msp",
        "./templates/cli/${org_domain}/peers/peer${num}.${org_domain}/tls:/etc/hyperledger/fabric/tls"
    ],
    "ports": [
      "${port1}:7051",
      "${port1}:7051",
    ],
    "command": "peer node start",
    "restart": "unless-stopped",
    "logging": {
      "driver": "json-file",
      "options": [
        "max-size: \"1m\"",
        "max-file: \"10\""
      ]
    }
  }
}

with io.open('data.yaml', 'w', encoding='utf8') as outfile:
    yaml.dump(base, outfile, default_flow_style=False, allow_unicode=True)