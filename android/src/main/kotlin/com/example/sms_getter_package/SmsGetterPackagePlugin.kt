package com.example.sms_getter_package

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

/**
 * SMS Getter Package Plugin (Kotlin)
 * 
 * This is the main plugin class that registers the SMS reading functionality
 * with the Flutter engine. It provides both new embedding API support and
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
class SmsGetterPackagePlugin : FlutterPlugin, ActivityAware {
    
    private val channelName = "sms_getter_package"
    private var channel: MethodChannel? = null
    private var smsReaderPlugin: SmsReaderPlugin? = null

    /**
     * Plugin registration for the new embedding API (Flutter 1.12+)
     * This method is called when the plugin is attached to the Flutter engine.
     * 
     * @param binding Flutter plugin binding containing the binary messenger
     */
    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // Create method channel for communication with Flutter
        channel = MethodChannel(binding.binaryMessenger, channelName)
        
        // Create SMS reader plugin instance
        smsReaderPlugin = SmsReaderPlugin()
        
        // Set method call handler to process Flutter method calls
        channel?.setMethodCallHandler(smsReaderPlugin)
        
        // Attach to engine
        smsReaderPlugin?.onAttachedToEngine(binding)
    }

    /**
     * Plugin cleanup when detached from the Flutter engine
     * This method is called when the plugin is removed from the Flutter engine.
     * 
     * @param binding Flutter plugin binding
     */
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up method call handler
        channel?.setMethodCallHandler(null)
        
        // Detach from engine
        smsReaderPlugin?.onDetachedFromEngine(binding)
    }

    /**
     * Activity attachment for permission handling
     * This method is called when the plugin is attached to an activity.
     * 
     * @param binding Activity plugin binding
     */
    override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
        smsReaderPlugin?.onAttachedToActivity(binding)
    }

    /**
     * Activity detachment for configuration changes
     * This method is called when the activity is detached for configuration changes.
     */
    override fun onDetachedFromActivityForConfigChanges() {
        smsReaderPlugin?.onDetachedFromActivityForConfigChanges()
    }

    /**
     * Activity reattachment after configuration changes
     * This method is called when the activity is reattached after configuration changes.
     * 
     * @param binding Activity plugin binding
     */
    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
        smsReaderPlugin?.onReattachedToActivityForConfigChanges(binding)
    }

    /**
     * Activity detachment
     * This method is called when the activity is detached.
     */
    override fun onDetachedFromActivity() {
        smsReaderPlugin?.onDetachedFromActivity()
    }

    companion object {
        /**
         * Legacy plugin registration for Flutter versions before 1.12
         * This method provides backward compatibility for older Flutter versions.
         * 
         * @param registrar Plugin registrar for legacy registration
         */
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            // Create method channel for legacy registration
            val channel = MethodChannel(registrar.messenger(), "sms_getter_package")
            
            // Create SMS reader plugin instance
            val smsReaderPlugin = SmsReaderPlugin()
            
            // Set method call handler
            channel.setMethodCallHandler(smsReaderPlugin)
            
            // Register with activity if available
            if (registrar.activity() != null) {
                // For legacy registration, we need to handle activity differently
                // The SmsReaderPlugin will handle permission requests through the activity
            }
        }
    }
}
