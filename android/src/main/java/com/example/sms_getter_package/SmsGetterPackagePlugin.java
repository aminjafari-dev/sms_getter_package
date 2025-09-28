package com.example.sms_getter_package;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

/**
 * SMS Getter Package Plugin
 * 
 * This is the main plugin class that registers the SMS reading functionality
 * with the Flutter engine. It handles both the new embedding API and the
 * legacy plugin registration for backward compatibility.
 * 
 * The plugin provides the following functionality:
 * - Reading SMS messages from the device
 * - Managing conversation threads
 * - Permission handling for SMS access
 * - Pagination support for large datasets
 * 
 * Usage in Flutter:
 * ```dart
 * final messages = await SmsGetterPackage.getAllSms();
 * ```
 */
public class SmsGetterPackagePlugin implements FlutterPlugin, ActivityAware {
    
    private static final String CHANNEL_NAME = "sms_getter_package";
    private MethodChannel channel;
    private SmsReaderPlugin smsReaderPlugin;

    /**
     * Plugin registration for the new embedding API (Flutter 1.12+)
     * This method is called when the plugin is attached to the Flutter engine.
     * 
     * @param binding Flutter plugin binding containing the binary messenger
     */
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        // Create method channel for communication with Flutter
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        
        // Create SMS reader plugin instance
        smsReaderPlugin = new SmsReaderPlugin();
        
        // Set method call handler to process Flutter method calls
        channel.setMethodCallHandler(smsReaderPlugin);
        
        // Attach to engine
        smsReaderPlugin.onAttachedToEngine(binding);
    }

    /**
     * Plugin cleanup when detached from the Flutter engine
     * This method is called when the plugin is removed from the Flutter engine.
     * 
     * @param binding Flutter plugin binding
     */
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // Clean up method call handler
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
        
        // Detach from engine
        if (smsReaderPlugin != null) {
            smsReaderPlugin.onDetachedFromEngine(binding);
        }
    }

    /**
     * Activity attachment for permission handling
     * This method is called when the plugin is attached to an activity.
     * 
     * @param binding Activity plugin binding
     */
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        if (smsReaderPlugin != null) {
            smsReaderPlugin.onAttachedToActivity(binding);
        }
    }

    /**
     * Activity detachment for configuration changes
     * This method is called when the activity is detached for configuration changes.
     */
    @Override
    public void onDetachedFromActivityForConfigChanges() {
        if (smsReaderPlugin != null) {
            smsReaderPlugin.onDetachedFromActivityForConfigChanges();
        }
    }

    /**
     * Activity reattachment after configuration changes
     * This method is called when the activity is reattached after configuration changes.
     * 
     * @param binding Activity plugin binding
     */
    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        if (smsReaderPlugin != null) {
            smsReaderPlugin.onReattachedToActivityForConfigChanges(binding);
        }
    }

    /**
     * Activity detachment
     * This method is called when the activity is detached.
     */
    @Override
    public void onDetachedFromActivity() {
        if (smsReaderPlugin != null) {
            smsReaderPlugin.onDetachedFromActivity();
        }
    }

}
