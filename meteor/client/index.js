var newChat = {name: 'Andrew'};

Template.toolbar.events({
  'click button.newChat': function () {    
    Chats.insert(newChat);
  },
  
  'click button.endChat': function () {

    var chat = Chats.findOne();
    if (chat) {
        Chats.remove(chat._id);
    }
  }
});

Template.main.chats = function() {
    return Chats.find();
}