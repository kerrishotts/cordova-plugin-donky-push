var DonkyPush = (function(){


    /*
     * Public API
     */
    var DonkyPush = {};

    /*DonkyPush.init = function(success, error, usePushUI) {
        if(typeof(usePushUI) === "undefined"){
            usePushUI = true;
        }
        return cordova.exec(success, error, 'DonkyPushPlugin', 'init', [usePushUI]);
    };*/

    return DonkyPush;
})();

module.exports = DonkyPush;