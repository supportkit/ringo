Meteor.startup(function() {
    console.log('meteor startup!');

    var key = parseInt(process.env.OPENTOK_KEY || Meteor.settings.env.OPENTOK_KEY);
    var secret = process.env.OPENTOK_SECRET || Meteor.settings.env.OPENTOK_SECRET;
    var opentok = new Meteor.require('opentok')(key, secret);

    if (!key || !secret) {
        console.error('Missing opentok credentials');
    }

    function createChat(participants) {

        var chat = Chats.insert({
            participants: participants
        });

        console.log('Created new chat: ' + chat);

        opentok.createSession(Meteor.bindEnvironment(function(err, session) {
            if (err) {
                console.error('Failed to create OpenTok session: ' + err);
            }
            console.log('Sucessfully created a new session: ' + session.sessionId);
            // now generate a tokens for all users

            _.each(participants, function(participant) {
                Users.update(participant, {
                    $set: {
                        sessionId: session.sessionId
                    }
                });
                generateToken(session.sessionId, participant);
            });
        }, function(e) {
            throw e;
        }));
    }

    function generateToken(sessionId, userId) {
        var token = opentok.generateToken(sessionId);
        console.log('Generated a token for ' + userId + ' : ' + token);
        Users.update(userId, {
            $set: {
                token: token
            }
        });
    }

    Meteor.methods({

        //
        // Dummy login. Give us your username and we'll simply return you your id
        //
        login: function(username) {
            return Users.findOne({
                username: username
            });
        },

        //
        // Simple queue logic
        // Match any end user to any agent who is also in the lobby
        //
        connect: function(userId) {
            var user = Users.findOne(userId);
            if (!user) {
                console.log('User ID not found: ' + userId);
                return;
            }

            if (user.state === 'lobby' || user.state === 'chat') {
                console.log(user.username + ' is already in the lobby or in a chat');
                return;
            }

            console.log(user.username + ' joined the lobby ' + user._id);
            Users.update(user._id, {
                $set: {
                    state: 'lobby'
                }
            });

            var endUser = Users.findOne({
                role: 'endUser',
                state: 'lobby'
            });
            var agent = Users.findOne({
                role: 'agent',
                state: 'lobby'
            });

            if (endUser && agent) {
                console.log('Connecting ' + endUser.username + '(user) to ' + agent.username + '(agent)');
                // We found a match, create a new chat
                Users.update(endUser._id, {
                    $set: {
                        state: 'chat',
                        otKey: '' + key
                    }
                });
                Users.update(agent._id, {
                    $set: {
                        state: 'chat',
                        otKey: '' + key
                    }
                });
                createChat([agent._id, endUser._id]);
            }
        },

        //
        // Simple disconnect logic. When any participant leaves the chat,
        // disconnect all other participants
        //
        disconnect: function(userId) {
            var chat;
            var user = Users.findOne(userId);
            if (!user) {
                console.log('User ID not found: ' + userId);
                return;
            }

            console.log(user.username + ' left the chat');
            Users.update(user._id, {
                $set: {
                    state: 'idle'
                },
                $unset: {
                    token: '',
                    sessionId: ''
                }
            });

            // Shut down any ongoing chats
            chat = Chats.findOne({
                participants: user._id
            });
            if (chat) {
                // Disconnect all users in the chat
                Users.update({
                    _id: {
                        $in: chat.participants
                    }
                }, {
                    $set: {
                        state: 'idle'
                    }
                });

                // Delete the chat
                Chats.remove(chat._id);
            }
        },

        reset: function() {
            console.log('Resetting user states');
            Users.update({}, {
                $set: {
                    state: 'idle'
                },
                $unset: {
                    token: '',
                    sessionId: ''
                }
            }, {
                multi: true
            });
            Chats.remove({});
        }

    });
});