var Donky = (function(){

    /*
     * Public API
     */
    var Donky = {};

    Donky.deviceready = false;
    Donky.donkyready = false;

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

    function checkAndDispatchDeviceAndDonkyReady(){
        if(Donky.donkyready && Donky.deviceready){
            var event = new CustomEvent('deviceanddonkyready');
            event.success = Donky.initSuccess;
            if(!event.success){
                event.errorMessage = Donky.initErrorMessage;
            }
            document.dispatchEvent(event);
        }
    }

    document.donkyready = function(success, errorMsg){
        Donky.donkyready = true;

        Donky.initSuccess = success;
        Donky.initErrorMessage = errorMsg;

        var event = new CustomEvent('donkyready');
        event.success = success;
        if(!event.success){
            event.errorMessage = errorMsg;
        }
        document.dispatchEvent(event);
        checkAndDispatchDeviceAndDonkyReady();
    };

    document.addEventListener("deviceready", function(){
        Donky.deviceready = true;
        checkAndDispatchDeviceAndDonkyReady();
    }, false);

    cordova.exec(null, null, 'DonkyPlugin', 'init', []);
    return Donky;
})();

module.exports = Donky;