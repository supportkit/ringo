// {
//     sessionId: '',
//     participants: [1234, 4321],
// }
Chats = new Meteor.Collection('chats');

// {
//     name: 'Amy',
//     role: 'agent' | 'endUser',
//     state: 'idle' || lobby' || 'chat'
//     token: 'opentoksession',
//     chatId: 123
// }
Users = new Meteor.Collection('users');

if (Meteor.isServer) {

    //
    // Create mock data
    //
    var testUsers = [{
        username: 'Amy',
        role: 'agent',
        state: 'idle'
    }, {
        username: 'Bob',
        role: 'endUser',
        state: 'idle'
    }];

    _.each(testUsers, function(user) {
        Users.upsert({
            username: user.username
        }, user);
    });

    Meteor.publish('users', function(userId) {
        return Users.find(userId);
    });

    Meteor.publish('chats', function(userId) {
        return Chats.find({
            participants: userId
        });
    });
}