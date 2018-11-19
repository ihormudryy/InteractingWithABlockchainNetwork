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

function readConfig() {
  if(fs.existsSync(SECRETS_DIR)) {
    const data = JSON.parse(fs.readFileSync(path.resolve(SECRETS_DIR, 'config')).toString());
    data.channelConfig = fs.readFileSync(path.resolve(SECRETS_DIR, 'channel'));
    return data;
  }
}

const config = readConfig();
//export default config;

hfc.addConfigFile(path.join(SECRETS_DIR, 'config.json'));

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// SET CONFIGURATONS ////////////////////////////
///////////////////////////////////////////////////////////////////////////////
app.options('*', cors());
app.use(cors());
//support parsing of application/json type post data
app.use(bodyParser.json());
//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({
	extended: false
}));

// set secret variable
app.set('secret', 'thisismysecret');
app.use(expressJWT({
	secret: 'thisismysecret'
}).unless({
	path: ['/users']
}));
app.use(bearerToken());
app.use(function(req, res, next) {
	logger.debug(' ------>>>>>> new request for %s',req.originalUrl);
	if (req.originalUrl.indexOf('/users') >= 0) {
		return next();
	}

	var token = req.token;
	jwt.verify(token, app.get('secret'), function(err, decoded) {
		if (err) {
			res.send({
				success: false,
				message: 'Failed to authenticate token. Make sure to include the ' +
					'token returned from /users call in the authorization header ' +
					' as a Bearer token'
			});
			return;
		} else {
			// add the decoded user name and org name to the request object
			// for the downstream code to use
			req.username = decoded.username;
			req.orgname = decoded.orgName;
			logger.debug(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.username, decoded.orgName));
			return next();
		}
	});
});