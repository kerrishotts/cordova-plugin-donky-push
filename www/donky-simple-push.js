var DonkyPush = (function(){


    /*
     * Public API
     */
    var DonkyPush = {};

    DonkyPush.init = function(success, error) {
        return cordova.exec(success, error, 'DonkyPushPlugin', 'init', []);
    };

    return DonkyPush;
})();

module.exports = DonkyPush;