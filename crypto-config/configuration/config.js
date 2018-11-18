//var readFileSync = require('fs').readFileSync;
var resolve = require('path').resolve;
var fs = require("fs");
const basePath = resolve(__dirname, './certs');
const readCryptoFile = filename => fs.readFileSync(resolve(basePath, filename)).toString();
const config = {
  channelName: 'mychannel',
  channelConfig: fs.readFileSync(resolve(__dirname, 'channel.tx')),
  chaincodeId: 'bcfit',
  chaincodeVersion: '1',
  chaincodePath: 'bcfit',
  rabbitmq: 'amqp://rabbitmq:5672?heartbeat=60',
  redisHost: 'redis-server',
  redisPort: 7000,
  iotDashUrl: 'https://think-iot-processor.mybluemix.net/steps?message=',
  orderer: {
    hostname: 'orderer0',
    url: 'grpcs://orderer0:7050',
    pem: readCryptoFile('ordererOrg.pem')
  },
  peers: [{
    peer: {
      hostname: 'shop-peer',
      url: 'grpcs://shop-peer:7051',
      eventHubUrl: 'grpcs://shop-peer:7053',
      pem: readCryptoFile('shopOrg.pem'),
      userKeystoreDBName: 'seller_db',
      userKeystoreDBUrl: 'http://ca-datastore:5984',
      stateDBName: 'member_db',
      stateDBUrl: 'http://shop-statedb:5984',
      org: 'org.ShopOrg',
      userType: 'seller'
    },
    ca: {
      hostname: 'shop-ca',
      url: 'https://shop-ca:7054',
      mspId: 'ShopOrgMSP',
      caName: 'shop-org'
    },
    admin: {
      key: readCryptoFile('Admin@shop-org-key.pem'),
      cert: readCryptoFile('Admin@shop-org-cert.pem')
    }
  }, {
    peer: {
      hostname: 'cryptocurrency-peer',
      url: 'grpcs://cryptocurrency-peer:8051',
      pem: readCryptoFile('cryptocurrencyOrg.pem'),
      userKeystoreDBName: 'user_db',
      userKeystoreDBUrl: 'http://ca-datastore:5984',
      stateDBName: 'member_db',
      stateDBUrl: 'http://cryptocurrency-statedb:5984',
      eventHubUrl: 'grpcs://cryptocurrency-peer:7053',
      org: 'org.CryptocurrencyOrg',
      userType: 'user'
    },
    ca: {
      hostname: 'cryptocurrency-ca',
      url: 'https://cryptocurrency-ca:8054',
      mspId: 'CryptocurrencyOrgMSP',
      caName: 'cryptocurrency-org'
    },
    admin: {
      key: readCryptoFile('Admin@cryptocurrency-org-key.pem'),
      cert: readCryptoFile('Admin@cryptocurrency-org-cert.pem')
    }
  }]
};
if(process.env.LOCALCONFIG) {
  config.orderer.url = 'grpcs://localhost:7050';
  config.peers[0].peer.url = 'grpcs://localhost:8051';
  config.peers[0].peer.eventHubUrl = 'grpcs://localhost:7053';
  config.peers[0].ca.url = 'https://localhost:5984';
  config.peers[0].peer.userKeystoreDBUrl = 'http://localhost:5984';
  config.peers[0].peer.stateDBUrl = 'http://localhost:9984';
  config.peers[1].peer.url = 'grpcs://localhost:8051';
  config.peers[1].peer.eventHubUrl = 'grpcs://localhost:8053';
  config.peers[1].ca.url = 'https://localhost:8054';
  config.peers[1].peer.userKeystoreDBUrl = 'http://localhost:5984';
  config.peers[1].peer.stateDBUrl = 'http://localhost:8984';
  config.rabbitmq = 'amqp://localhost:5672?heartbeat=60';
  config.redisHost = 'localhost';
  config.iotDashUrl = 'https://think-iot-processor.mybluemix.net/steps?message=';
}
//export default config;
fs.writeFile("./config.json", JSON.stringify(config), (err) => {
  if(err) {
    console.error(err);
    return;
  }
  console.log("File has been created");
});
