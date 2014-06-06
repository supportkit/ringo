exports = module.exports = function(listening_app, dispatch) {
    var io = require('socket.io').listen(listening_app);

    io.configure(function () {
      io.set("transports", ["xhr-polling"]);
      io.set("polling duration", 10);
    });
    
    io.sockets.on('connection', function(socket) {

        socket.on('agent_signal', function(data) {
            io.sockets.emit('agent_signal_relay', data);
        });

        socket.on('agent_draw', function(data) {
            io.sockets.emit('agent_draw_relay', data);
        });

        socket.on('agent_clear', function(data) {
            io.sockets.emit('agent_clear_relay', data);
        });
    });

    dispatch.on('screenshot_update', function(data) {
        io.sockets.emit('screenshot_update', data);
    });
};