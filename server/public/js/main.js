/*globals document,io,TB,fileExists*/
$(document).ready(function() {
    var key = 44833552;
    var api = {
        chat: document.location.href + 'api/chat',
        restart: document.location.href + 'api/restart'
    };


    // Functions
    var startVideoChat;
    var connect;
    var disconnect;

    // Selectors
    var inputName = $('input#name');
    var connectButton = $('#connectButton');
    var buttonRestart = $('button#restart');
    var formConnectAsUser = $('form#connectAsUser');
    var connectionIndicator = $('#connectionIndicator');
    var videoWrapper = $('.video-wrapper');
    var mirrorContainer = $('#mirrorContainer');
    var mirrorImg = $('#mirrorContainer img');
    var drawTool = $('#drawTool');
    var signalTool = $('#signalTool');
    var clearTool = $('#clearTool');
    var drawCanvas = $('#drawCanvas');

    var getEventCoords = function(e) {
        var x = e.offsetX ? e.offsetX : e.clientX - $(e.target).offset().left;
        var y = e.offsetY ? e.offsetY : e.clientY - $(e.target).offset().top;
        console.log('x:' + x + ' y:' + y + ' w:' + e.currentTarget.offsetWidth);
        return {
            x: x,
            y: y,
            w: e.currentTarget.offsetWidth,
        };
    };

    var draw = {
        start: function(drawPane) {
            var points = [];
            var lastPoint;
            var canvasEl = document.getElementById('drawCanvas');
            canvasEl.width = drawPane.width();
            canvasEl.height = drawPane.height();
            var ctx = canvasEl.getContext('2d');

            ctx.strokeStyle = 'orange';
            ctx.lineWidth = 13;
            ctx.lineJoin = 'round';
            ctx.lineCap = 'round';

            var paint = function(point) {
                if (lastPoint) {
                    console.log("Canvas w: " + ctx.canvas.width + " h: " + ctx.canvas.height);
                    ctx.beginPath();
                    ctx.moveTo(lastPoint.x, lastPoint.y);
                    ctx.lineTo(point.x, point.y);
                    ctx.closePath();
                    ctx.stroke();
                }
            };

            var mousedown = function(e) {
                points = [];
                drawPane.on('mousemove', mousemove);
            };

            var mouseup = function(e) {
                lastPoint = null;
                drawPane.unbind('mousemove');
                socket.emit('agent_draw', JSON.stringify(points));
            };

            var mousemove = function(e) {
                var newPoint = getEventCoords(e);
                paint(newPoint);
                lastPoint = newPoint;
                points.push(newPoint);
                e.preventDefault();
            };

            drawPane.on('mousedown', mousedown);
            drawPane.on('mouseup', mouseup);
        },

        stop: function(drawPane) {
            drawPane.unbind('mousedown');
            drawPane.unbind('mouseup');
            drawPane.unbind('mousemove');
        }
    };

    var signal = {
        start: function(drawPane) {
            drawPane.on('click', function(e) {
                var point = getEventCoords(e);
                var canvasEl = document.getElementById('drawCanvas');
                canvasEl.width = drawPane.width();
                canvasEl.height = drawPane.height();
                var ctx = canvasEl.getContext('2d');

                var radius = 30;
                var circ = Math.PI * 2;
                var circleStart = Math.PI * 1.5;
                var curPercent = 0;

                ctx.lineWidth = 7;
                ctx.strokeStyle = 'lime';

                var animate = function(current) {
                    ctx.beginPath();
                    ctx.arc(point.x, point.y, radius, circleStart, circleStart - ((circ) * current), true);
                    ctx.stroke();
                    curPercent = curPercent + 3;
                    if (curPercent < 100) {
                        window.requestAnimationFrame(function() {
                            animate((curPercent + 10) / 100);
                        });
                    }
                };

                animate();

                setTimeout(function() {
                    ctx.clearRect(0, 0, drawPane.width(), drawPane.height());
                }, 1000);

                socket.emit('agent_signal', JSON.stringify(point));
            });
        },

        stop: function(drawPane) {
            drawPane.unbind('click');
        }
    };

    // State
    var session;
    var selectedTool;

    // =======================================================================
    // Mirroring & remote control
    // =======================================================================
    signalTool.on('click', function() {
        selectedTool = signal;
        draw.stop(drawCanvas);
        signal.start(drawCanvas);
    });

    drawTool.on('click', function() {
        selectedTool = draw;
        signal.stop(drawCanvas);
        draw.start(drawCanvas);
    });

    clearTool.on('click', function() {
        var canvasEl = document.getElementById("drawCanvas");
        var ctx = canvasEl.getContext('2d');
        ctx.clearRect(0, 0, drawCanvas.width(), drawCanvas.height());
        socket.emit('agent_clear');
    });


    var socket = io.connect(document.location.href);

    var toggleRotation = function(orientation) {
        if (mirrorContainer.hasClass('landscape')) {
            mirrorContainer.removeClass('landscape');
            mirrorContainer.addClass('portrait');
        } else {
            mirrorContainer.removeClass('portrait');
            mirrorContainer.addClass('landscape');
        }

        if (selectedTool) {
            selectedTool.start(drawCanvas);
        }
    };

    mirrorImg.on('error', function() {
        mirrorImg.css('visibility', 'hidden');
    });

    mirrorImg.on('dragstart', function(e) {
        e.preventDefault();
    });

    mirrorImg.on('click', function(e) {
        var x = e.offsetX ? e.offsetX : e.clientX - $(e.target).offset().left;
        var y = e.offsetY ? e.offsetY : e.clientY - $(e.target).offset().top;
        var coords = {
            x: x,
            y: y,
            width: e.currentTarget.offsetWidth,
        };
        socket.emit('agent_click_ui', JSON.stringify(coords));
    });

    var mirror = function() {
        var screenshotUpdate = 'screenshot_update';
        var screenshotUrl = '/img/screenshot.jpg';

        return {
            start: function() {
                socket.on(screenshotUpdate, function(e) {
                    var orientation = JSON.parse(e).orientation;
                    if (!mirrorContainer.hasClass(orientation)) {
                        toggleRotation();
                    }
                    mirrorImg.css('visibility', 'visible').css('cursor', 'crosshair');
                    mirrorImg.attr('src', screenshotUrl + "?_=" + new Date().getTime());
                });
            },
            stop: function() {
                socket.removeAllListeners(screenshotUpdate);
            }
        };
    }();

    // =======================================================================
    // UI event handlers
    // =======================================================================
    formConnectAsUser.submit(function(event) {
        startVideoChat(inputName.val());
        event.preventDefault();
    });

    connectButton.on('click', function() {
        if (session) {
            disconnect();
        } else {
            startVideoChat();
            $('#connectionIndicator').html($('<span class="disconnected">Waiting for user...</span>'));
            connectButton.attr('disabled', 'disabled');
        }
    });

    buttonRestart.on('click', function() {
        $.ajax(api.restart, function(res) {
            startVideoChat();
        });
    });

    var onConnected = function() {
        connectButton.removeAttr('disabled');
        connectButton.removeClass('connect').addClass('disconnect');
        videoWrapper.css('display', 'block');
    };

    var onDisconnected = function() {
        connectButton.removeClass('disconnect').addClass('connect');
        connectionIndicator.removeClass('connected').addClass('disconnected');
        $('#connectionIndicator').html($('<span class="disconnected">Disconnected</span>'));
        mirrorImg.css('visibility', 'hidden').css('cursor', 'default');
    };

    $('#toggleDebug').on('click', function(e) {
        var debugPanel = $('.debugPanel');
        var newVis = (debugPanel.css('display') === 'block') ? 'none' : 'block';
        debugPanel.css('display', newVis);
        e.preventDefault();
    });

    // =======================================================================
    // OpenTok
    // =======================================================================
    startVideoChat = function(name) {
        var url = api.chat;
        if (name) {
            url = api.chat + "?name=" + name;
        }

        $.ajax(url)
            .done(function(res) {
                connect(res);
            });
    };

    connect = function(chatData) {
        $('#sessionId').text(chatData.sessionId);

        TB.addEventListener("exception", exceptionHandler);
        session = TB.initSession(chatData.sessionId); // Replace with your own session ID. See https://dashboard.tokbox.com/projects
        TB.setLogLevel(TB.DEBUG);
        session.addEventListener("sessionConnected", sessionConnectedHandler);
        session.addEventListener("streamCreated", streamCreatedHandler);
        session.addEventListener("sessionDisconnected", streamDisconnectedHandler);
        session.connect(key, chatData.token);

        function sessionConnectedHandler(event) {
            mirror.start();
            onConnected();
            subscribeToStreams(event.streams);

            var publisher = TB.initPublisher(key,
                "localVideoElement", {
                    width: 200,
                    height: 150
                });

            session.publish(publisher);
        }

        function streamCreatedHandler(event) {
            subscribeToStreams(event.streams);
        }

        function streamDisconnectedHandler(event) {
            onDisconnected();
        }

        function subscribeToStreams(streams) {
            for (var i = 0; i < streams.length; i++) {
                var stream = streams[i];
                if (stream.connection.connectionId != session.connection.connectionId) {
                    session.subscribe(stream, "remoteVideoElement", {
                        width: 200,
                        height: 150
                    });

                    var connectionData = JSON.parse(stream.connection.data);
                    $('#connectionIndicator').html($('<span class="connected">Connected to </span><span class="nameTag">' + connectionData.name + '</span>'));
                }
            }
        }

        function exceptionHandler(event) {
            alert(event.message);
        }
    };

    disconnect = function() {
        mirror.stop();
        if (session) {
            session.disconnect();
            session = null;
        }
    };
});