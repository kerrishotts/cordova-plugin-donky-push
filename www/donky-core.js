var DonkyCore = (function(){


    /*
     * Public API
     */
    var DonkyCore = {};

    DonkyCore._notificationTypeCallbacks = {};

    DonkyCore.init = function(success, error, apiKey, userDetails, deviceDetails, appVersion) {
        if(userDetails){
            userDetails = JSON.stringify(userDetails);
        }
        if(deviceDetails){
            deviceDetails = JSON.stringify(deviceDetails);
        }
        return cordova.exec(success, error, 'DonkyCorePlugin', 'init', [apiKey, userDetails, deviceDetails, appVersion]);
    };

    DonkyCore.updateUserDetails = function(success, error, userDetails) {
        return cordova.exec(success, error, 'DonkyCorePlugin', 'updateUserDetails', [JSON.stringify(userDetails)]);
    };

    DonkyCore.updateDeviceDetails = function(success, error, deviceDetails) {
        return cordova.exec(success, error, 'DonkyCorePlugin', 'updateDeviceDetails', [JSON.stringify(deviceDetails)]);
    };

    DonkyCore.updateRegistrationDetails = function(success, error, userDetails, deviceDetails) {
        return cordova.exec(success, error, 'DonkyCorePlugin', 'updateRegistrationDetails', [JSON.stringify(userDetails), JSON.stringify(deviceDetails)]);
    };

    DonkyCore.replaceRegistrationDetails = function(success, error, userDetails, deviceDetails) {
        return cordova.exec(success, error, 'DonkyCorePlugin', 'replaceRegistrationDetails', [JSON.stringify(userDetails), JSON.stringify(deviceDetails)]);
    };

    DonkyCore.sendContentNotificationToUser  = function(success, error, userId, notificationType, data, queue){
        if(typeof(queue) === "undefined"){
            queue = false;
        }
        return cordova.exec(success, error, 'DonkyCorePlugin', 'sendContentNotificationToUser', [userId, notificationType, JSON.stringify(data), queue]);
    };

    DonkyCore.sendContentNotificationToUsers  = function(success, error, users, notificationType, data, queue){
        if(typeof(queue) === "undefined"){
            queue = false;
        }
        return cordova.exec(success, error, 'DonkyCorePlugin', 'sendContentNotificationToUsers', [JSON.stringify(users), notificationType, JSON.stringify(data), queue]);
    };

    DonkyCore.synchronise = function(success, error) {
        return cordova.exec(success, error, 'DonkyCorePlugin', 'synchronise', []);
    };

    DonkyCore.subscribeToContentNotifications = function(success, error, notificationType, handlerFn){

        DonkyCore._notificationTypeCallbacks[notificationType] = function(data){
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

        return cordova.exec(success, error, 'DonkyCorePlugin', 'subscribeToContentNotifications', [notificationType]);
    };
    return DonkyCore;
})();

module.exports = DonkyCore;