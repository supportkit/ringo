var session;
var otKey;

OpentokHelper = {
    disconnect: function() {
        if (session) {
            session.disconnect();
        }
    },

    connect: function(user) {
        otKey = user.otKey;
        console.log('Connecting to OpenTok session ' + user.sessionId);

        TB.addEventListener("exception", exceptionHandler);
        session = TB.initSession(user.sessionId); // Replace with your own session ID. See https://dashboard.tokbox.com/projects
        TB.setLogLevel(TB.DEBUG);
        session.addEventListener("sessionConnected", sessionConnectedHandler);
        session.addEventListener("streamCreated", streamCreatedHandler);
        session.addEventListener("sessionDisconnected", streamDisconnectedHandler);
        session.connect(otKey, user.token);

        function sessionConnectedHandler(event) {
            console.log('TB: session connected');
            subscribeToStreams(event.streams);

            var publisher = TB.initPublisher(otKey,
                "localVideoElement", {
                    width: 200,
                    height: 150
                });

            session.publish(publisher);
        }

        function streamCreatedHandler(event) {
            console.log('TB: stream created');
            subscribeToStreams(event.streams);
        }

        function streamDisconnectedHandler(event) {
            console.log('TB: stream disconnected');
            onDisconnected();
        }

        function subscribeToStreams(streams) {
            console.log('TB: subscribe to streams');
            for (var i = 0; i < streams.length; i++) {
                var stream = streams[i];
                console.log('TB: stream id: ' + stream.connection.connectionId);
                if (stream.connection.connectionId != session.connection.connectionId) {
                    console.log('TB: remote video element');
                    session.subscribe(stream, "remoteVideoElement", {
                        width: 200,
                        height: 150
                    });

                    //TODO: Use meteor for this bit
                    var connectionData = JSON.parse(stream.connection.data);
                    $('#connectionIndicator').html($('<span class="connected">Connected to </span><span class="nameTag">' + connectionData.name + '</span>'));
                }
            }
        }

        function exceptionHandler(event) {
            alert(event.message);
        }
    }
};