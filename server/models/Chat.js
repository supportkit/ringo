var mongoose = require('mongoose');

var chatSchema = new mongoose.Schema({
    sessionId: String
});

module.exports = mongoose.model('Chat', chatSchema);