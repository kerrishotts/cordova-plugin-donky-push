package cordova.plugin;

import android.app.Application;
import android.util.Log;

import net.donky.core.DonkyCore;
import net.donky.core.DonkyException;
import net.donky.core.DonkyListener;
import net.donky.core.ModuleDefinition;
import net.donky.core.analytics.DonkyAnalytics;
import net.donky.core.messaging.push.ui.DonkyPushUI;

import java.util.Map;

public class DonkyApplication extends Application
{
    public static final String TAG = "DonkyApplication";
    public static final String API_KEY = "JqUcc3JGT8ZLtZtWNG+3BSzt+QCBw4vLdUl7NzKWo4oRfRUWUXca2uPnWVfg+uFoyVORPWcgK3CHUBvXCcvELg";

    protected ModuleDefinition moduleDefinition;

    @Override
    public void onCreate()
    {
        Log.d(TAG, "onCreate()");
        super.onCreate();

        // Init Analytics module
        DonkyAnalytics.initialiseAnalytics(this,
                new DonkyListener() {
                    @Override
                    public void success() {
                        handleDonkySuccessCallback("Analytics module initialised");
                    }

                    @Override
                    public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                        handleDonkyErrorCallback("Failed to initialise analytics module", donkyException, validationErrors);
                    }
                });

        // Init Push module
        DonkyPushUI.initialiseDonkyPush(this,
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

        // Init Core module
        DonkyCore.initialiseDonkySDK(this,
            API_KEY,
            new DonkyListener(){
                @Override
                public void success() {
                    moduleDefinition = new ModuleDefinition(TAG, "1.0.0.0");
                    handleDonkySuccessCallback("Successfully initialised Core module");
                }

                @Override
                public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                    handleDonkyErrorCallback("Error initialising Core module", donkyException, validationErrors);
                }
        });
    }


    private void handleDonkySuccessCallback(String message){
        Log.d(TAG, message);
    }

    private void handleDonkyErrorCallback(String message, DonkyException donkyException, Map<String, String> validationErrors){
        if (donkyException != null) {
            message.concat("; exception: " + donkyException.getMessage());
        }
        if (validationErrors != null) {
            message.concat("; validation errors: " + validationErrors.toString());
        }
        Log.e(TAG, message);
    }

}
