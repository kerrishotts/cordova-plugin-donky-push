
package cordova.plugin;

import android.app.Activity;
import android.app.Application;
import android.util.Log;

import net.donky.core.DonkyException;
import net.donky.core.DonkyListener;
import net.donky.core.messaging.push.logic.DonkyPushLogic;
import net.donky.core.messaging.push.ui.DonkyPushUI;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.Map;

/**
 * Cordova Plugin that wraps the Donky Simple Push Logic SDK
 */
public class DonkyPushPlugin extends CordovaPlugin {
    public static final String TAG = "DonkyPushPlugin";


    /**
     * Cordova callback context
     */
    protected CallbackContext context;


    /**
     * Constructor.
     */
    public DonkyPushPlugin() {}


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
     * Initialises the Donky Push SDK
     * @throws Exception
     */
    protected void init(JSONArray args) throws JSONException {

        boolean usePushUI = args.getBoolean(0);
        final Application application = this.cordova.getActivity().getApplication();

        if(usePushUI){
            DonkyPushUI.initialiseDonkyPush(application,
                    new DonkyListener() {
                        @Override
                        public void success() {
                            handleDonkySuccessCallback("success initialising Donky Push UI/Logic");
                        }

                        @Override
                        public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                            handleDonkyErrorCallback("failed to initialise Donky Push UI/Logic", donkyException, validationErrors);
                        }
                    });
        }else{
            DonkyPushLogic.initialiseDonkyPush(application,
                    new DonkyListener() {
                        @Override
                        public void success() {
                            handleDonkySuccessCallback("success initialising Donky Push Logic");
                        }

                        @Override
                        public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                            handleDonkyErrorCallback("failed to initialise Donky Push Logic", donkyException, validationErrors);
                        }
                    });
        }
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
}