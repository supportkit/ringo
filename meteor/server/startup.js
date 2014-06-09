Meteor.startup(function () {
    console.log('meteor startup!');

    Meteor.methods({
        foo: function() {
            console.log('Someone called foo');
        },

        bar: function(arg1) {
            console.log('Someone called bar with ' + arg1);
            return('From server: bar ' + arg1);
        }
    })
});