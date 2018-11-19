# Interacting with a Blockchain Network

## Instructions for setting the blockchainNetwork

Welcome to Part 2 of building a Blockchain Application.  Now that you have created a blockchain network, you can learn how to interact with it to add participants, perform transactions and query the network.

## Included Components
* Hyperledger Fabric
* Docker
* Hyperledger Fabric SDK for node.js

1. Run a build script that launches the network in 3 steps.
2. Ensure that all old Docker images are removed so you build the network from a clean system.
3. Generate the cryptographic material. The Crypto configuration file (crypto-config.yaml) defines the identity of who is who. It tells peers and orderers what organization and domain they belong to. It then initializes a blockchain network or channel and services with an Orderer Genesis Block, which serves as the first chain block. Membership services are installed on each channel peer.
4. Install the chaincode on the peers, and build the Docker images of the orderer, peers, channel, network.
5. Launch the network.
6. View transction logs
7. Perform transactions using application
8. view results of transactions in web application

## Prerequisites
* [Docker](https://www.docker.com/products/overview) - v1.13 or higher
* [Docker Compose](https://docs.docker.com/compose/overview/) - v1.8 or higher

## Steps
1. [Run Build.sh Script to build network](#1-run-the-build.sh-script)
2. [Check the logs](#2-check-the-logs)
3. [Test commands on the network](#3-Test-commands-on-the-network)


## 1. Run the Build.sh Script

### Open a new terminal and run the following command:

This step will do the following:

* Remove docker images and containers

* Remove old certificates

* Create and instantiate certificates on the peers in the network

* Start the blockchain network

**Note: the `build.sh` command will run a long time; perhaps 3-4 mins

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


## 2. Check the logs

This step will check the log results from runnng the `./build.sh` command.

**Command**
```bash
docker logs blockchain-setup
```
**Output:**
```bash
CA registration complete 
CA registration complete 
Default channel not found, attempting creation...
Successfully created a new default channel.
Joining peers to the default channel.
Chaincode is not installed, attempting installation...
Base container image present.
info: [packager/Golang.js]: packaging GOLANG from bcfit
info: [packager/Golang.js]: packaging GOLANG from bcfit
Successfully installed chaincode on the default channel.
Successfully instantiated chaincode on all peers.
Blockchain newtork setup complete.
```

**Command**
```bash
docker ps
```

**Command**
```bash
docker logs cryptocurrency_cryptocurrency-backend_1
```
**Output:**
```
CA registration complete 
CA registration complete 
CA registration complete 
[x] Awaiting RPC requests on clientClient2
[x] Awaiting RPC requests on clientClient0
[x] Awaiting RPC requests on clientClient1
```

**Command**
```bash
docker logs cryptocurrency_shop-backend_1
```
**Output:**
```
CA registration complete 
CA registration complete 
Starting socker server
[x] Awaiting RPC requests on clientClient0
```

## 3.  Test commands on the network


**To view the Blockchain Events**

In a separate terminal navigate to testApplication folder and run the following command:
```
cd testApplication
npm install
node index.js
```
Navigate to url to view the blockchain blocks: **http://localhost:8000/history.html**
Now navigate to url to perform operations on network : **http://localhost:8000/test.html**

**Sample  values for request**



**Enroll Operation**
```
type = enroll
userId = <leave blank>
fcn = <leave blank>
args = <leave blank>
```

From this you will see a return message for a User ID:  (`e0165a07-9358-470e-b29d-9412b7967000` is the id that is dynamically created)

```
{"message":"success","result":{"user":"e0165a07-9358-470e-b29d-9412b7967000","txId":"dfc8b4849a2fe4352ff1213c7445fbe2ecdb649f444580c6d010a1fca3fb990d"}}
```


**Invoke Operation** (This will create a user with 500 cryptocurrencys)
```
type = invoke
userId = e0165a07-9358-470e-b29d-9412b7967000
fcn = createMember
args = <userID>,<Number as String> i.e. e0165a07-9358-470e-b29d-9412b7967000,500 
```

From this you will see a return message: (500 cryptocurrencys were created)

```
{"message":"success","result":{"txId":"82700302bd916df4aecc9685150d0e5e9ba8a385407fbd1d80b7f03c5c474255","results":{"status":200,"message":"","payload":"{\"id\":\"e0165a07-9358-470e-b29d-9412b7967000\",\"memberType\":\"user\",\"cryptocurrencysBalance\":5,\"totalSteps\":500,\"stepsUsedForConversion\":500,\"contractIds\":null,\"generatedFitcoins\":5}"}}}
```

**Invoke Operation** (Alternative way to generate 500 cryptocurrencys)
```
type = invoke
userId = e0165a07-9358-470e-b29d-9412b7967000
fcn = generateFitcoins
args = <userID>,<Number as String> i.e. e0165a07-9358-470e-b29d-9412b7967000,500
```


**Query Operation**
```
type = query
userId = <userID> i.e. e0165a07-9358-470e-b29d-9412b7967000
fcn = getState
args = <userID> i.e. e0165a07-9358-470e-b29d-9412b7967000
```

From this you will see a return message: (It shows that this userid has 500 cryptocurrencys)
```
{"message":"success","result":"{\"contractIds\":null,\"cryptocurrencysBalance\":5,\"id\":\"e0165a07-9358-470e-b29d-9412b7967000\",\"memberType\":\"user\",\"stepsUsedForConversion\":500,\"totalSteps\":500}"}
```


## Additional Resources
* [Hyperledger Fabric Docs](http://hyperledger-fabric.readthedocs.io/en/latest/)
* [Hyperledger Composer Docs](https://hyperledger.github.io/composer/introduction/introduction.html)

## License
[Apache 2.0](LICENSE)
