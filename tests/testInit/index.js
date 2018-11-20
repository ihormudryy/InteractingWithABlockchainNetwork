'use strict';

const fs = require('fs');
const path = require('path');
const SECRETS_DIR = process.env.SECRETSDIR || '/run/secrets';

var log4js = require('log4js');
var logger = log4js.getLogger('SampleWebApp');
var express = require('express');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var http = require('http');
var util = require('util');
var app = express();
var expressJWT = require('express-jwt');
var jwt = require('jsonwebtoken');
var bearerToken = require('express-bearer-token');
var cors = require('cors');
var hfc = require('fabric-client');

var helper = require('./helpers/helper.js');
var channel = require('./helpers/channel.js');
var chaincode = require('./helpers/chaincode.js');
var updateAnchorPeers = require('./helpers/update-anchor-peers.js');
var query = require('./helpers/query.js');

logger.setLevel('DEBUG');
hfc.addConfigFile(path.join(SECRETS_DIR, 'config.json'));

var peers = hfc.getConfigSetting('peers');
var channelObj = null;
var channelName = hfc.getConfigSetting('channelName');
var channelConfig = hfc.getConfigSetting('channelConfig');

for (const key in peers){
  var userName =  peers[key]["admin"]["name"];
  var orgName = peers[key]["peer"]["org"];
  var peerName = peers[key]["peer"]["hostname"];
  if (channelObj === null) {
    channelObj = channel.createChannel(channelName, channelConfig, userName, orgName);
  } 
  //channel.joinChannel(channelName, peerName, userName, orgName);
}