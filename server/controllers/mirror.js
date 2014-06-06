var fs = require('fs');
var path = require('path');
var screenshotPath = 'public/img/screenshot.jpg';

var saveScreenshot = function(src, dest, callback) {
    var is = fs.createReadStream(src);
    var os = fs.createWriteStream(dest);
    is.pipe(os);
    is.on('end', function(err) {
        fs.unlinkSync(src);
        if (err) {
            callback(err);
        } else {
            callback();
        }
    });
};

exports = module.exports = function(dispatch) {

    return {
        upload: function(req, res) {
            //TODO
            if (!req.files || !req.files.source) {
                res.send(400, 'Bad Request: No files attached in the source field');
            }

            saveScreenshot(req.files.source.path, screenshotPath, function(err) {
                if (err) {
                    res.send(500, err);
                } else {
                    var data = {
                        orientation: req.param('orientation') || 'landscape'
                    };
                    dispatch.emit('screenshot_update', JSON.stringify(data));
                    res.send(200);
                }
            });
        }
    };
};