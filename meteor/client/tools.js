Tool = function() {};

Tool.prototype.getEventCoords = function(e) {
    var x = e.offsetX ? e.offsetX : e.clientX - $(e.target).offset().left;
    var y = e.offsetY ? e.offsetY : e.clientY - $(e.target).offset().top;
    return {
        x: x,
        y: y,
        w: e.currentTarget.offsetWidth,
    };
};

//
// Drawing
//
DrawTool = function() {};

DrawTool.prototype = new Tool();

DrawTool.prototype.start = function(drawCanvas) {
    var self = this;
    var points = [];
    var lastPoint;
    var canvasEl = drawCanvas[0];
    canvasEl.width = drawCanvas.width();
    canvasEl.height = drawCanvas.height();
    var ctx = canvasEl.getContext('2d');

    ctx.strokeStyle = 'orange';
    ctx.lineWidth = 13;
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';

    var paint = function(point) {
        if (lastPoint) {
            ctx.beginPath();
            ctx.moveTo(lastPoint.x, lastPoint.y);
            ctx.lineTo(point.x, point.y);
            ctx.closePath();
            ctx.stroke();
        }
    };

    var mousedown = function(e) {
        points = [];
        drawCanvas.on('mousemove', mousemove);
    };

    var mouseup = function(e) {
        lastPoint = null;
        drawCanvas.unbind('mousemove');
        drawCanvas.trigger('draw', {points: points} );
    };

    var mousemove = function(e) {
        var newPoint = self.getEventCoords(e);
        paint(newPoint);
        lastPoint = newPoint;
        points.push(newPoint);
        e.preventDefault();
    };

    drawCanvas.on('mousedown', mousedown);
    drawCanvas.on('mouseup', mouseup);
};

DrawTool.prototype.stop = function(drawCanvas) {
    drawCanvas.unbind('mousedown');
    drawCanvas.unbind('mouseup');
    drawCanvas.unbind('mousemove');
};

//
// Signalling
//
SignalTool = function() {};

SignalTool.prototype = new Tool();

SignalTool.prototype.start = function(drawCanvas) {
    var self = this;

    drawCanvas.on('click', function(e) {
        var point = self.getEventCoords(e);
        var canvasEl = drawCanvas[0];
        canvasEl.width = drawCanvas.width();
        canvasEl.height = drawCanvas.height();
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
            ctx.clearRect(0, 0, drawCanvas.width(), drawCanvas.height());
        }, 1000);

        drawCanvas.trigger('signal', point );
    });
};

SignalTool.prototype.stop = function(drawCanvas) {
    drawCanvas.unbind('click');
};

//
// Clear Tool
//
ClearTool = function() {};

ClearTool.prototype.clear = function(drawCanvas) {
    var canvasEl = drawCanvas[0];
    var ctx = canvasEl.getContext('2d');
    ctx.clearRect(0, 0, drawCanvas.width(), drawCanvas.height());
};