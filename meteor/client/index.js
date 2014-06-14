function getUsername() {
    return Session.get('username');
}

Template.toolbar.events({
    'click .amy': function() {
        Session.set('username', 'Amy');
    },

    'click .bob': function() {
        Session.set('username', 'Bob');
    },

    'click button.connect': function() {
        Meteor.call('connect', getUsername());
    },

    'click button.disconnect': function() {
        OpentokHelper.disconnect();
        Meteor.call('disconnect', getUsername());
    },

    'click button.reset': function() {
        Meteor.call('reset');
    }

});

Template.main.chats = function() {
    return Chats.find();
};

Template.main.lobby = function() {
    return Users.find({state: 'lobby'});
};

Template.chat.participants = function() {
    return Users.find({_id: {$in: this.participants}});
};

function getUser() {   
    return Users.findOne({username: getUsername()});
}

function getChat() {
    var currentUser = getUser();
    return currentUser && Chats.findOne({participants: currentUser._id});
}

Meteor.startup(function() {
    console.log('client startup!');  

    Deps.autorun(function() {
        console.log('Subscribing to chats');
        Meteor.subscribe('users', getUsername());
        Meteor.subscribe('chats', getUsername());

        Users.find({username: getUsername()}).observeChanges({
            changed: function(id, fields) {
                console.log('Saw a user field change! ' + id + ' fields: ' + JSON.stringify(fields));
                if (fields && fields.token) {
                    OpentokHelper.connect(getUser());
                }
            }
        });
    });


});