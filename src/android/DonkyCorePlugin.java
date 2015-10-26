
package cordova.plugin;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import android.os.Bundle;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import net.donky.core.DonkyCore;
import net.donky.core.DonkyException;
import net.donky.core.DonkyListener;
import net.donky.core.ModuleDefinition;
import net.donky.core.NotificationBatchListener;
import net.donky.core.Subscription;
import net.donky.core.account.DeviceDetails;
import net.donky.core.account.DonkyAccountController;
import net.donky.core.account.UserDetails;
import net.donky.core.events.OnCreateEvent;
import net.donky.core.events.OnPauseEvent;
import net.donky.core.events.OnResumeEvent;
import net.donky.core.network.DonkyNetworkController;
import net.donky.core.network.ServerNotification;
import net.donky.core.network.content.ContentNotification;

import org.json.JSONObject;

/**
 * Cordova Plugin that wraps the Donky Core SDK
 */
public class DonkyCorePlugin extends CordovaPlugin {
    public static final String TAG = "DonkyCorePlugin";


    /**
     * Cordova callback context
     */
    protected CallbackContext context;

    protected ModuleDefinition moduleDefinition;

    /**
     * Constructor.
     */
    public DonkyCorePlugin() {}


    /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArray of arguments for the plugin.
     * @param callbackContext   The callback id used when calling back into JavaScript.
     * @return                  True if the action was valid, false if not.
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        boolean result = true;
        context = callbackContext;

        Log.d(TAG, "action: ".concat(action));
        try {
            if(action.equals("init")) {
                this.init(args);
            }else if(action.equals("updateUserDetails")) {
                this.updateUserDetails(args);
            }else if(action.equals("updateDeviceDetails")) {
                this.updateDeviceDetails(args);
            }else if(action.equals("updateRegistrationDetails")) {
                this.updateRegistrationDetails(args);
            }else if(action.equals("replaceRegistrationDetails")) {
                this.replaceRegistrationDetails(args);
            }else if(action.equals("sendContentNotificationToUser")) {
                this.sendContentNotificationToUser(args);
            }else if(action.equals("sendContentNotificationToUsers")) {
                this.sendContentNotificationToUsers(args);
            }else if(action.equals("synchronise")) {
                this.synchronise();
            }else if(action.equals("subscribeToContentNotifications")) {
                this.subscribeToContentNotifications(args, callbackContext);
            }else {
                handleError("Invalid action");
                result = false;
            }
        }catch(Exception e ) {
            handleError(e.getMessage());
            result = false;
        }
        return result;
    }

    /**
     * Initialises the Donky Core SDK
     * @param args JSONArray of arguments containing API key, device details and user details
     * @throws Exception
     */
    protected void init(JSONArray args) throws Exception {
        UserDetails userDetails = null;
        DeviceDetails deviceDetails = null;

        String apiKey = args.getString(0);
        if(apiKey == "null"){
            throw new Exception("API key not specified when calling init()");
        }

        String jsUserDetails = args.getString(1);
        String jsDeviceDetails = args.getString(2);
        String appVersion = args.getString(3);

        if(jsUserDetails != "null"){
            Log.d(TAG, "Setting user details");
            userDetails = getUserDetailsFromJson(jsUserDetails);
        }

        if(jsDeviceDetails != "null") {
            Log.d(TAG, "Setting device details");
            deviceDetails = getDeviceDetailsFromJson(jsDeviceDetails);
        }

        DonkyAnalytics.initialiseAnalytics(this.cordova.getActivity().getApplication(),
            new DonkyListener(){
                @Override
                public void success() {
                    Log.d(TAG, "Analytics module initialised");
                }

                @Override
                public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                    Log.e(TAG, "Failed to initialise analytics module");
                }
        });

        DonkyCore.initialiseDonkySDK(this.cordova.getActivity().getApplication(),
            apiKey,
            userDetails,
            deviceDetails,
            appVersion,
            new DonkyListener(){
                @Override
                public void success() {
                    moduleDefinition = new ModuleDefinition(TAG, "1.0.0.0");
                    handleDonkySuccessCallback("success initialising");
                }

                @Override
                public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                    handleDonkyErrorCallback("failed to initialise", donkyException, validationErrors);
                }
        });
    }

    /**
     * Updates registered user details
     * @param args JSONArray of arguments containing new user details
     * @throws Exception
     */
    protected void updateUserDetails(JSONArray args) throws Exception {
        String jsUserDetails = args.getString(0);
        if(jsUserDetails == "null"){
            throw new Exception("user details not specified when calling updateUserDetails()");
        }
        UserDetails userDetails = getUserDetailsFromJson(jsUserDetails);
        DonkyAccountController.getInstance().updateUserDetails(userDetails,
            new DonkyListener() {
                @Override
                public void success() {
                    handleDonkySuccessCallback("successfully updated user details");
                }

                @Override
                public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                    handleDonkyErrorCallback("failed to update user details", donkyException, validationErrors);
                }
            });
    }

    /**
     * Updates registered device details
     * @param args JSONArray of arguments containing new device details
     * @throws Exception
     */
    protected void updateDeviceDetails(JSONArray args) throws Exception {
        String jsDeviceDetails = args.getString(0);
        if(jsDeviceDetails == "null"){
            throw new Exception("device details not specified when calling updateDeviceDetails()");
        }
        DeviceDetails deviceDetails = getDeviceDetailsFromJson(jsDeviceDetails);
        DonkyAccountController.getInstance().updateDeviceDetails(deviceDetails,
            new DonkyListener() {
                @Override
                public void success() {
                    handleDonkySuccessCallback("successfully updated device details");
                }

                @Override
                public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                    handleDonkyErrorCallback("failed to update device details", donkyException, validationErrors);
                }
            });
    }

    /**
     * Updates registered user and device details
     * @param args JSONArray of arguments containing new user and device details
     * @throws Exception
     */
    protected void updateRegistrationDetails(JSONArray args) throws Exception {
        String jsUserDetails = args.getString(0);
        if(jsUserDetails == "null"){
            throw new Exception("user details not specified when calling updateRegistrationDetails()");
        }
        String jsDeviceDetails = args.getString(1);
        if(jsDeviceDetails == "null"){
            throw new Exception("device details not specified when calling updateRegistrationDetails()");
        }

        UserDetails userDetails = getUserDetailsFromJson(jsUserDetails);
        DeviceDetails deviceDetails = getDeviceDetailsFromJson(jsDeviceDetails);
        DonkyAccountController.getInstance().updateRegistrationDetails(userDetails, deviceDetails,
                new DonkyListener() {
                    @Override
                    public void success() {
                        handleDonkySuccessCallback("successfully updated registration details");
                    }

                    @Override
                    public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                        handleDonkyErrorCallback("failed to update registration details", donkyException, validationErrors);
                    }
                });
    }

    /**
     * Replaces registered user and device details
     * @param args JSONArray of arguments containing new user and device details
     * @throws Exception
     */
    protected void replaceRegistrationDetails(JSONArray args) throws Exception {
        String jsUserDetails = args.getString(0);
        if(jsUserDetails == "null"){
            throw new Exception("user details not specified when calling updateRegistrationDetails()");
        }
        String jsDeviceDetails = args.getString(1);
        if(jsDeviceDetails == "null"){
            throw new Exception("device details not specified when calling updateRegistrationDetails()");
        }

        UserDetails userDetails = getUserDetailsFromJson(jsUserDetails);
        DeviceDetails deviceDetails = getDeviceDetailsFromJson(jsDeviceDetails);
        DonkyAccountController.getInstance().replaceRegistration(userDetails, deviceDetails,
                new DonkyListener() {
                    @Override
                    public void success() {
                        handleDonkySuccessCallback("successfully replaced registration details");
                    }

                    @Override
                    public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                        handleDonkyErrorCallback("failed to replace registration details", donkyException, validationErrors);
                    }
                });
    }

    /**
     * Sends a content notification to a single user
     * @param args JSONArray of arguments containing target user ID, notification type and content data
     * @throws Exception
     */
    protected void sendContentNotificationToUser(JSONArray args) throws Exception {
        String userId = args.getString(0);
        String notificationType = args.getString(1);

        String jsData = args.getString(2);
        JSONObject data = new JSONObject(jsData);

        boolean queue = args.getBoolean(3);

        ContentNotification contentNotification = new ContentNotification(userId, notificationType, data);

        if(queue){
            this.queueContentNotification(contentNotification);
        }else{
            this.sendContentNotification(contentNotification);
        }
    }

    /**
     * Sends a content notification to a multiple users
     * @param args JSONArray of arguments containing target user IDs, notification type and content data
     * @throws Exception
     */
    protected void sendContentNotificationToUsers(JSONArray args) throws Exception {
        String jsUsers = args.getString(0);
        List<String> users = new Gson().fromJson(jsUsers, new TypeToken<List<String>>() {
        }.getType());
        String notificationType = args.getString(1);

        String jsData = args.getString(2);
        JSONObject data = new JSONObject(jsData);

        boolean queue = args.getBoolean(3);

        ContentNotification contentNotification = new ContentNotification(users, notificationType, data);

        if(queue){
            this.queueContentNotification(contentNotification);
        }else{
            this.sendContentNotification(contentNotification);
        }
    }

    /**
     * Synchronises locally and remotely queued notifications with the Donky network
     */
    protected void synchronise(){
        DonkyNetworkController.getInstance().synchronise(
                new DonkyListener() {
                    @Override
                    public void success() {
                        handleDonkySuccessCallback("successfully synchronised notifications");
                    }

                    @Override
                    public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                        handleDonkyErrorCallback("failed to synchronise notifications", donkyException, validationErrors);
                    }
                });
    }

    protected void subscribeToContentNotifications(JSONArray args, final CallbackContext callbackContext) throws Exception {
        final String notificationType = args.getString(0);
        try{
            Subscription<ServerNotification> subscription =
                    new Subscription<ServerNotification>(notificationType,
                    new NotificationBatchListener<ServerNotification>() {
                        @Override
                        public void onNotification(ServerNotification notification) {}

                        @Override
                        public void onNotification(List<ServerNotification> notifications) {
                            try{
                                Log.d(TAG, "Received notifications for custom type: ".concat(notificationType));
                                for(ServerNotification notification : notifications) {
                                    com.google.gson.JsonObject jsonObject = notification.getData();
                                    String jsData = jsonObject.toString();
                                    jsNotificationCallback(jsData, notificationType);
                                }
                            }catch(Exception e ) {
                                Log.e(TAG, "Error parsing received notifications for custom type '"+notificationType+"':"+e.getMessage());
                                String jsData = String.format("{error: \"%s\"}", e.getMessage());
                                jsNotificationCallback(jsData, notificationType);
                            }
                        }
            });
            DonkyCore.subscribeToContentNotifications(this.moduleDefinition, subscription);
            handleDonkySuccessCallback("Subscribed to custom notification type: ".concat(notificationType));
        }catch(Exception e ) {
            Log.e(TAG, "Error subscribing for notifications of custom type '"+notificationType+"':"+e.getMessage());
            callbackContext.error(e.getMessage());
        }
    }

    private void jsNotificationCallback(String jsData, String notificationType){
        String jsStatement = String.format("cordova.plugins.donky.core._notificationTypeCallbacks[\"%s\"](%s);", notificationType, jsData);
        executeGlobalJavascript(jsStatement);
    }

    /**
     * Adds a content notification to the local queue
     * @param contentNotification Content notification to add to queue
     */
    private void queueContentNotification(ContentNotification contentNotification){
        DonkyNetworkController.getInstance().queueContentNotification(contentNotification);
        handleDonkySuccessCallback("successfully queued content notification");
    }

    /**
     * Sends a content notification immediately
     * @param contentNotification Content notification to send
     */
    private void sendContentNotification(ContentNotification contentNotification){
        DonkyNetworkController.getInstance().sendContentNotification(contentNotification,
                new DonkyListener() {
                    @Override
                    public void success() {
                        handleDonkySuccessCallback("successfully sent content notification");
                    }

                    @Override
                    public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                        handleDonkyErrorCallback("failed to send content notification", donkyException, validationErrors);
                    }
                });
    }

    /**
     * Handles an error while executing a plugin API method.
     * Calls the registered Javascript plugin error handler callback.
     * @param errorMsg Error message to pass to the JS error handler
     */
    private void handleError(String errorMsg){
        try {
            Log.e(TAG, errorMsg);
            context.error(errorMsg);
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
    }

    /**
     * Handles successful response to an operation by the Donky SDK.
     * Calls the registered Javascript plugin success handler callback.
     * @param message Message to pass to the JS success handler
     */
    private void handleDonkySuccessCallback(String message){
        Log.d(TAG, message);
        context.success(message);
    }

    /**
     * Handlers error response to an operation by the Donky SDK.
     * Calls the registered Javascript plugin error handler callback.
     * @param message Message to pass to the JS error handler
     * @param donkyException An exception that occurred
     * @param validationErrors Validation errors that occurred
     */
    private void handleDonkyErrorCallback(String message, DonkyException donkyException, Map<String, String> validationErrors){
        if (donkyException != null) {
            message.concat("; exception: " + donkyException.getMessage());
        }
        if (validationErrors != null) {
            message.concat("; validation errors: " + validationErrors.toString());
        }
        handleError(message);
    }

    /**
     * Parses a JSON string into a UserDetails object
     * @param json String contain user details
     * @return UserDetails object
     * @throws JSONException
     */
    private UserDetails getUserDetailsFromJson(String json) throws JSONException{
        JSONObject oUserDetails = new JSONObject(json);
        UserDetails userDetails = new UserDetails();

        if(oUserDetails.has("userId")){
            userDetails.setUserId(oUserDetails.getString("userId"));
        }
        if(oUserDetails.has("displayName")){
            userDetails.setUserDisplayName(oUserDetails.getString("displayName"));
        }
        if(oUserDetails.has("firstName")){
            userDetails.setUserFirstName(oUserDetails.getString("firstName"));
        }
        if(oUserDetails.has("lastName")){
            userDetails.setUserLastName(oUserDetails.getString("lastName"));
        }
        if(oUserDetails.has("emailAddress")){
            userDetails.setUserEmailAddress(oUserDetails.getString("emailAddress"));
        }
        if(oUserDetails.has("mobileNumber")){
            userDetails.setUserMobileNumber(oUserDetails.getString("mobileNumber"));
        }
        if(oUserDetails.has("countryCode")){
            userDetails.setUserCountryCode(oUserDetails.getString("countryCode"));
        }
        if(oUserDetails.has("avatarId")){
            userDetails.setUserAvatarId(oUserDetails.getString("avatarId"));
        }

        if (oUserDetails.has("additionalProperties")) {
            String jsAdditionalProperties = oUserDetails.getString("additionalProperties");
            Map<String, String> hmAdditionalProperties = new Gson().fromJson(jsAdditionalProperties, new TypeToken<HashMap<String, String>>() {}.getType());
            TreeMap<String, String> additionalProperties = new TreeMap<String, String>(hmAdditionalProperties);
            userDetails.setUserAdditionalProperties(additionalProperties);
        }

        if (oUserDetails.has("selectedTags")) {
            JSONArray aSelectedTags = oUserDetails.getJSONArray("selectedTags");
            List<String> lSelectedTags = new ArrayList<String>();
            int length = aSelectedTags.length();
            for(int i=0; i<length; i++){
                lSelectedTags.add(aSelectedTags.getString(i));
            }
            Set<String> selectedTags = new HashSet<String>(lSelectedTags);
            userDetails.setSelectedTags(selectedTags);
        }
        return userDetails;
    }

    /**
     * Parses a JSON string into a DeviceDetails object
     * @param json String contain device details
     * @return DeviceDetails object
     * @throws JSONException
     */
    private DeviceDetails getDeviceDetailsFromJson(String json) throws JSONException{
        JSONObject oDeviceDetails = new JSONObject(json);
        String deviceName = "";
        String deviceType = "";
        TreeMap additionalProperties = null;

        if (oDeviceDetails.has("deviceName")) {
            deviceName = oDeviceDetails.getString("deviceName");
        }
        if (oDeviceDetails.has("deviceType")) {
            deviceType = oDeviceDetails.getString("deviceType");
        }
        if (oDeviceDetails.has("additionalProperties")) {
            String jsAdditionalProperties = oDeviceDetails.getString("additionalProperties");
            Map<String, String> hmAdditionalProperties = new Gson().fromJson(jsAdditionalProperties, new TypeToken<HashMap<String, String>>() {}.getType());
            additionalProperties = new TreeMap<String, String>(hmAdditionalProperties);
        }
        DeviceDetails deviceDetails = new DeviceDetails(deviceName, deviceType, additionalProperties);
        return deviceDetails;
    }

    private void executeGlobalJavascript(final String jsString){
        cordova.getActivity().runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
                webView.loadUrl("javascript:" + jsString);
            }
        });
    }

    /*
     * Overrides
     */

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        DonkyCore.publishLocalEvent(new OnCreateEvent(this.cordova.getActivity().getIntent()));
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);
        DonkyCore.publishLocalEvent(new OnPauseEvent());
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        DonkyCore.publishLocalEvent(new OnResumeEvent());
    }

}