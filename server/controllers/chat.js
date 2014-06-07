var secrets = require('../config/secrets');
if (!secrets.openTok.key || !secrets.openTok.secret) {
    console.error('Missing OpenTok key and secret in config/secrets.js');
}
var OpenTok = require('opentok');
var opentok = new OpenTok(secrets.openTok.key, secrets.openTok.secret);
var async = require('async');
var Chat = require('../models/Chat');

// Our global sessionId
var sessionId = '';
var agentName = 'Amy';

var createSession = function(callback) {
    opentok.createSession(function(err, session) {
        console.log('Sucessfully created a new session: ' + session.sessionId);
        callback(null, session);
    });
};

var getSessionId = function(callback) {
    console.log('Getting sessionId..');
    async.waterfall([

            function(callback) {
                Chat.findOne().exec(callback);
            },
            function(sessionId, callback) {
                if (sessionId) {
                    console.log('Found an existing sessionId...');
                    callback(null, sessionId);
                } else {
                    console.log('Creating a new session...');
                    createSession(function(err, session) {
                        console.log('Saving the new session...');
                        new Chat({
                            sessionId: session.sessionId
                        }).save(callback);
                    });
                }
            }
        ],
        function(err, result) {
            if (err) {
                callback(err);
            } else {
                callback(null, result.sessionId);
            }
        });
};

//
// GET /api/chat
//
exports.chat = function(req, res) {
    var name = req.param('name') || 'anonymous';
    var responseObj = {
        agentName: agentName
    };
    async.waterfall([

            function(callback) {
                getSessionId(callback);
            },

            function(sessionId, callback) {
                var sid = sessionId.sessionId ? sessionId.sessionId : sessionId;
                console.log('Getting token ' + sid);
                responseObj.sessionId = sid;
                responseObj.token = opentok.generateToken(sid);
                console.log("Response Object: " + JSON.stringify(responseObj));
                callback(null, responseObj);
            }
        ],
        function(err, result) {
            if (err) {
                res.send(500, err);
            } else {
                res.send(200, result);
            }
        });
};

//
// GET /api/restart
//
exports.restart = function(req, res) {
    async.parallel({

            // Lookup the persisted chat object
            chat: function(callback) {
                console.log('calling findOne...');
                Chat.findOne().exec(callback);
            },

            // Fetch a new sessionId from OpenTok
            newSession: createSession
        },
        function(err, result) {
            if (err) {
                res.send(500, err);
            } else {
                result.chat.sessionId = result.newSession.sessionId;
                result.chat.save(function(err) {
                    if (err) {
                        res.send(500, err);
                    } else {
                        res.send(200);
                    }
                });
            }
        });
};