## Instructions for setting the blockchainNetwork

### Open a new terminal and run the following command:
```bash
export FABRIC_CFG_PATH=$(pwd)
chmod +x cryptogen
chmod +x configtxgen
chmod +x ./rabbitCluster/cluster-entrypoint.sh
chmod +x generate-certs.sh
chmod +x generate-cfgtx.sh
chmod +x docker-images.sh
chmod +x build.sh
chmod +x clean.sh
./build.sh
```

### Add compactions for CouchDB instances

In browser, open the web UI for all the couchdb instances and add the compaction rule.

For eg:
* Open  ```http://<IPAddress>:<Port>/_utils```
* http://localhost:8984/_utils
* Now select the Configuration tab and click on the `Add Option` button.
* Provide the following values for the input fields:
```
Selection: compactions
Option: _default
Value: [{db_fragmentation, "30%"}, {view_fragmentation, "30%"}]
```
* Now using terminal, do the following curl request for all the DB's:
Format :
```
curl -H "Content-Type: application/json" -X POST http://<IPAddress>:<Port>/<DBName>/_compact
```
###  Check the logs

**Command**
```bash
docker logs blockchain-setup
```
**Output:**
```bash
Register CA cryptocurrency-org
CA registration complete  FabricCAServices : {hostname: cryptocurrency-ca, port: 7054}
Register CA shop-org
CA registration complete  FabricCAServices : {hostname: shop-ca, port: 7054}
info: [EventHub.js]: _connect - options {"grpc.ssl_target_name_override":"shop-peer","grpc.default_authority":"shop-peer"}
info: [EventHub.js]: _connect - options {"grpc.ssl_target_name_override":"cryptocurrency-peer","grpc.default_authority":"cryptocurrency-peer"}
Default channel not found, attempting creation...
Successfully created a new default channel.
Joining peers to the default channel.
Chaincode is not installed, attempting installation...
Base container image present.
info: [packager/Golang.js]: packaging GOLANG from bcfit
info: [packager/Golang.js]: packaging GOLANG from bcfit
Successfully installed chaincode on the default channel.
Successfully instantiated chaincode on all peers.
```


**Command**
```bash
docker logs cryptocurrency-backend
```
**Output:**
```
Register CA cryptocurrency-org
CA registration complete  FabricCAServices : {hostname: cryptocurrency-ca, port: 7054}
Register CA cryptocurrency-org
CA registration complete  FabricCAServices : {hostname: cryptocurrency-ca, port: 7054}
info: [EventHub.js]: _connect - options {"grpc.ssl_target_name_override":"cryptocurrency-peer","grpc.default_authority":"cryptocurrency-peer","grpc.max_receive_message_length":-1,"grpc.max_send_message_length":-1}
info: [EventHub.js]: _connect - options {"grpc.ssl_target_name_override":"cryptocurrency-peer","grpc.default_authority":"cryptocurrency-peer","grpc.max_receive_message_length":-1,"grpc.max_send_message_length":-1}
connected to the server
creating server queue connection user_queue
 [x] Awaiting RPC requests
```

**Command**
```bash
docker logs cryptocurrency_shop-backend_1
```
**Output:**
```
Register CA shop-org
CA registration complete  FabricCAServices : {hostname: shop-ca, port: 7054}
Register CA shop-org
CA registration complete  FabricCAServices : {hostname: shop-ca, port: 7054}
info: [EventHub.js]: _connect - options {"grpc.ssl_target_name_override":"shop-peer","grpc.default_authority":"shop-peer","grpc.max_receive_message_length":-1,"grpc.max_send_message_length":-1}
info: [EventHub.js]: _connect - options {"grpc.ssl_target_name_override":"shop-peer","grpc.default_authority":"shop-peer","grpc.max_receive_message_length":-1,"grpc.max_send_message_length":-1}
Starting socker server
connected to the server
creating server queue connection seller_queue
 [x] Awaiting RPC requests
```

**Scale the fictoin-backend**

To scale the cryptocurrency-backend use the following command:
```bash
docker-compose -p "cryptocurrency" up -d --scale cryptocurrency-backend=<No of conatiners>
```

**To run the load test application**

Check the instructions from [start.md](https://github.com/IBM/secret-map-dashboard/blob/master/containers/blockchain/cliLoadTester/start.md)

**To view the Blockchain Events**

In a separate terminal navigate to testApplication folder and run the following command:
```
npm install
node index.js
```
Navigate to url to view the blockchain blocks: **http://localhost:8000/history.html**
Now navigate to url to perform operations on network : **http://localhost:8000/test.html**

**Sample  values for request**

**Invoke Operation**
```
type = invoke
userId = <userID> i.e. user1
fcn = generateFitcoins
args = <userID>,<Number as String> i.e. user1,"500"
```

**Query Operation**
```
type = query
userId = <userID> i.e. user1
fcn = getState
args = <userID> i.e. user1
```
