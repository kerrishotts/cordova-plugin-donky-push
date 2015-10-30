cordova.define("cordova-plugin-donky-simple-push.donky-core", function(require, exports, module) { var Donky = (function(){

    /*
     * Public API
     */
    var Donky = {};

    Donky._notificationTypeCallbacks = {};

    Donky.updateUserDetails = function(success, error, userDetails) {
        return cordova.exec(success, error, 'DonkyPlugin', 'updateUserDetails', [JSON.stringify(userDetails)]);
    };

    Donky.updateDeviceDetails = function(success, error, deviceDetails) {
        return cordova.exec(success, error, 'DonkyPlugin', 'updateDeviceDetails', [JSON.stringify(deviceDetails)]);
    };

    Donky.updateRegistrationDetails = function(success, error, userDetails, deviceDetails) {
        return cordova.exec(success, error, 'DonkyPlugin', 'updateRegistrationDetails', [JSON.stringify(userDetails), JSON.stringify(deviceDetails)]);
    };

    Donky.replaceRegistrationDetails = function(success, error, userDetails, deviceDetails) {
        return cordova.exec(success, error, 'DonkyPlugin', 'replaceRegistrationDetails', [JSON.stringify(userDetails), JSON.stringify(deviceDetails)]);
    };

    Donky.sendContentNotificationToUser  = function(success, error, userId, notificationType, data, queue){
        if(typeof(queue) === "undefined"){
            queue = false;
        }
        return cordova.exec(success, error, 'DonkyPlugin', 'sendContentNotificationToUser', [userId, notificationType, JSON.stringify(data), queue]);
    };

    Donky.sendContentNotificationToUsers  = function(success, error, users, notificationType, data, queue){
        if(typeof(queue) === "undefined"){
            queue = false;
        }
        return cordova.exec(success, error, 'DonkyPlugin', 'sendContentNotificationToUsers', [JSON.stringify(users), notificationType, JSON.stringify(data), queue]);
    };

    Donky.synchronise = function(success, error) {
        return cordova.exec(success, error, 'DonkyPlugin', 'synchronise', []);
    };

    Donky.subscribeToContentNotifications = function(success, error, notificationType, handlerFn){

        Donky._notificationTypeCallbacks[notificationType] = function(data){
            try{
                if(typeof(data) === "string"){
                    data = JSON.parse(data);
                }
                handlerFn(data);
            }catch(e){
                handlerFn({
                    error: e.message,
                    customType: notificationType
                });
            }
        };

        return cordova.exec(success, error, 'DonkyPlugin', 'subscribeToContentNotifications', [notificationType]);
    };
                                                                                                            
    document.donkyready = function(){
      document.dispatchEvent(new CustomEvent('donkyready'));
    };
                                                                                                                
    cordova.exec(null, null, 'DonkyPlugin', 'init', []);
                                                                                                                
    return Donky;
})();

module.exports = Donky;
});
