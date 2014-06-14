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
    if (Users.find().count() === 0) {
        Users.insert({
            username: 'Amy',
            role: 'agent',
            state: 'idle'
        });

        Users.insert({
            username: 'Bob',
            role: 'endUser',
            state: 'idle'
        });
    }

    Meteor.publish('users', function (username) {
        return Users.find({username: username});
    });

    Meteor.publish('chats', function (username) {
        return Chats.find({participants: username});
    });  
}
