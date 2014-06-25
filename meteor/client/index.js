var user;
var drawTool;
var signalTool;
var tool;

Meteor.startup(function() {
    drawTool = new DrawTool();
    signalTool = new SignalTool();
    tool = drawTool;
});

Template.debugTools.events({
    
    'click .amy': function() {
        Session.set('username', 'Amy');
    },

    'click .bob': function() {
        Session.set('username', 'Bob');
    },

    'click button.connect': function() {
        Meteor.call('connect', getUserId());
    },

    'click button.disconnect': function() {
        OpentokHelper.disconnect();
        Meteor.call('disconnect', getUserId());
    },

    'click button.reset': function() {
        Meteor.call('reset');
    }

});

Template.toolbar.events({

    'click #signalTool': function() {
        var drawCanvas = $('#drawCanvas');
        tool.stop(drawCanvas);
        tool = signalTool;
        signalTool.start(drawCanvas);
    },

    'click #drawTool': function() {
        var drawCanvas = $('#drawCanvas');
        tool.stop(drawCanvas);
        tool = drawTool;
        drawTool.start(drawCanvas);
    }
});

Template.device.events({

    'draw #drawCanvas': function(event, source, data) {
        console.log('TODO: send draw event', JSON.stringify(data));
    },

    'signal #drawCanvas': function(event, source, data) {
        console.log('TODO: send signal event', JSON.stringify(data));  
    }
});

Template.main.chats = function() {
    return Chats.find();
};

Template.main.lobby = function() {
    return Users.find({
        state: 'lobby'
    });
};

Template.chat.participants = function() {
    return Users.find({
        _id: {
            $in: this.participants
        }
    });
};

function getChatId() {
    var chat = user && Chats.findOne({
        participants: getUserId()
    });

    return chat && chat._id;
}

function getUserId() {
    return user && user._id;
}

function onLogin(err, result) {
    if (err) {
        console.error('Error logging in');
        return;
    }

    user = result;
    console.log('Subscribing to events for ' + result.username);
    Meteor.subscribe('users', getUserId());
    Meteor.subscribe('chats', getUserId());

    Users.find(getUserId()).observeChanges({
        changed: function(id, fields) {
            console.log('Saw a user field change! ' + id + ' fields: ' + JSON.stringify(fields));
            if (fields && fields.token) {
                OpentokHelper.connect(Users.findOne(getUserId()));
            }
        }
    });
}

Meteor.startup(function() {
    console.log('client startup!');

    Deps.autorun(function() {
        var username = Session.get('username');
        if (username) {
            Meteor.call('login', username, onLogin);
        }
    });
});