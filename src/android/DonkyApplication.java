package cordova.plugin;

import android.app.Application;
import android.content.res.XmlResourceParser;
import android.util.Log;

import com.mobiledonky.example.push.R;

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
    public static final String CONFIG_PREFERENCE_NAME = "DONKY_API_KEY";

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
                this.readApiKey(),
            new DonkyListener(){
                @Override
                public void success() {
                    moduleDefinition = new ModuleDefinition(TAG, "1.0.0.0");
                    handleDonkySuccessCallback("Successfully initialised Core module");
                    DonkyPlugin.sdkIsReady(null);
                }

                @Override
                public void error(DonkyException donkyException, Map<String, String> validationErrors) {
                    handleDonkyErrorCallback("Error initialising Core module", donkyException, validationErrors);
                    String message = donkyException.getMessage();
                    if (validationErrors != null) {
                        message = message.concat("; validation errors: " + validationErrors.toString());
                    }
                    DonkyPlugin.sdkIsReady(message);
                }
        });
    }


    private void handleDonkySuccessCallback(String message){
        Log.d(TAG, message);
    }

    private void handleDonkyErrorCallback(String message, DonkyException donkyException, Map<String, String> validationErrors){
        if (donkyException != null) {
            message = message.concat("; exception: " + donkyException.getMessage());
        }
        if (validationErrors != null) {
            message = message.concat("; validation errors: " + validationErrors.toString());
        }
        Log.e(TAG, message);
    }

    protected String readApiKey(){
        String key = "";

        try {
            XmlResourceParser xrp = getResources().getXml(R.xml.config);
            int eventType;
            while((eventType = xrp.next()) != XmlResourceParser.END_DOCUMENT)
            {
                if (eventType == XmlResourceParser.START_TAG) {
                    if(xrp.getName().equalsIgnoreCase("preference")
                            && xrp.getAttributeValue(null, "name").equalsIgnoreCase(CONFIG_PREFERENCE_NAME)){
                        key = xrp.getAttributeValue(null, "value");
                        Log.d(TAG, "Found Donky API key in config.xml: "+key);
                        break;
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            e.printStackTrace();
        }

        if(key == ""){
            Log.e(TAG, "Donky API key not found in config.xml");
        }

        return key;
    }

}
