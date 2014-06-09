Meteor.startup(function () {
    console.log('client startup!');

    console.log('Subscribing to chats');    
    Meteor.subscribe('chats');

    Meteor.call('bar', 'from javascript', function() {
        console.log('bar callback!');
    });
});