Chats = new Meteor.Collection('chats');

if (Meteor.isServer) {

  Meteor.publish('chats', function () {
    return Chats.find();
  });
  
}