package com.example.sms_getter_package;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.provider.Telephony;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * SMS Reader Plugin for Flutter
 * 
 * This plugin provides functionality to read SMS messages from the device's SMS database.
 * It requires READ_SMS permission to access SMS messages.
 * 
 * Usage example:
 * ```dart
 * final smsPlugin = SmsReaderPlugin();
 * final messages = await smsPlugin.getAllSms();
 * ```
 */
public class SmsReaderPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    
    private static final String CHANNEL = "sms_getter_package";
    private static final String METHOD_GET_ALL_SMS = "getAllSms";
    private static final String METHOD_GET_SMS_BY_ADDRESS = "getSmsByAddress";
    private static final String METHOD_GET_CONVERSATIONS = "getConversations";
    private static final String METHOD_GET_CONVERSATION_MESSAGES = "getConversationMessages";
    private static final String METHOD_GET_MESSAGES_BY_ADDRESS = "getMessagesByAddress";
    private static final String METHOD_CHECK_PERMISSION = "checkPermission";
    private static final String METHOD_REQUEST_PERMISSION = "requestPermission";
    
    private MethodChannel channel;
    private Context context;
    private ActivityPluginBinding activityPluginBinding;
    
    /**
     * Constructor for SMS Reader Plugin
     * @param context Android application context
     */
    public SmsReaderPlugin() {
        this.context = null; // Will be set when attached to engine
    }
    
    private SmsReaderPlugin(Context context) {
        this.context = context;
    }
    
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
        context = binding.getApplicationContext();
    }
    
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
    
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activityPluginBinding = binding;
    }
    
    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.activityPluginBinding = null;
    }
    
    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.activityPluginBinding = binding;
    }
    
    @Override
    public void onDetachedFromActivity() {
        this.activityPluginBinding = null;
    }
    
    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case METHOD_GET_ALL_SMS:
                getAllSms(result);
                break;
            case METHOD_GET_SMS_BY_ADDRESS:
                String smsAddress = call.argument("address");
                getSmsByAddress(smsAddress, result);
                break;
            case METHOD_GET_CONVERSATIONS:
                // Get pagination parameters from Flutter (default to 0 = all conversations)
                int limit = call.argument("limit") != null ? (int) call.argument("limit") : 0;
                int offset = call.argument("offset") != null ? (int) call.argument("offset") : 0;
                getConversations(limit, offset, result);
                break;
            case METHOD_GET_CONVERSATION_MESSAGES:
                String threadId = call.argument("threadId");
                getConversationMessages(threadId, result);
                break;
            case METHOD_GET_MESSAGES_BY_ADDRESS:
                String addressParam = call.argument("address");
                getMessagesByAddress(addressParam, result);
                break;
            case METHOD_CHECK_PERMISSION:
                checkPermission(result);
                break;
            case METHOD_REQUEST_PERMISSION:
                requestPermission(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }
    
    /**
     * Retrieves all SMS messages from the device
     * This method reads all SMS messages from the device's SMS database
     * and returns them as a list of maps containing SMS details.
     * 
     * @param result Flutter result callback
     */
    private void getAllSms(Result result) {
        // Check if READ_SMS permission is granted
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_SMS) 
                != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "READ_SMS permission is required", null);
            return;
        }
        
        try {
            List<Map<String, Object>> smsList = new ArrayList<>();
            
            // Query SMS inbox using ContentResolver
            // Using Telephony.Sms.URI for accessing SMS messages
            Uri uri = Telephony.Sms.CONTENT_URI;
            String[] projection = {
                Telephony.Sms._ID,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
                Telephony.Sms.DATE_SENT,
                Telephony.Sms.TYPE,
                Telephony.Sms.READ
            };
            
            String sortOrder = Telephony.Sms.DATE + " DESC";
            
            Cursor cursor = context.getContentResolver().query(
                uri, projection, null, null, sortOrder
            );
            
            if (cursor != null) {
                try {
                    while (cursor.moveToNext()) {
                        Map<String, Object> smsMap = new HashMap<>();
                        smsMap.put("id", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms._ID)));
                        smsMap.put("address", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)));
                        smsMap.put("body", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY)));
                        smsMap.put("date", cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)));
                        smsMap.put("dateSent", cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE_SENT)));
                        smsMap.put("type", cursor.getInt(cursor.getColumnIndexOrThrow(Telephony.Sms.TYPE)));
                        smsMap.put("read", cursor.getInt(cursor.getColumnIndexOrThrow(Telephony.Sms.READ)));
                        
                        smsList.add(smsMap);
                    }
                } finally {
                    cursor.close();
                }
            }
            
            result.success(smsList);
            
        } catch (Exception e) {
            result.error("SMS_READ_ERROR", "Error reading SMS messages: " + e.getMessage(), null);
        }
    }
    
    /**
     * Checks if READ_SMS permission is granted
     * This method verifies if the application has the necessary permission
     * to read SMS messages from the device.
     * 
     * @param result Flutter result callback
     */
    private void checkPermission(Result result) {
        boolean hasPermission = ActivityCompat.checkSelfPermission(
            context, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED;
        result.success(hasPermission);
    }
    
    /**
     * Requests READ_SMS permission from the user
     * This method shows the system permission dialog to request SMS permission.
     * Note: This method is primarily for compatibility. The permission_handler
     * plugin handles the actual permission request flow in Flutter.
     * 
     * @param result Flutter result callback
     */
    private void requestPermission(Result result) {
        try {
            // Check current permission status first
            boolean hasPermission = ActivityCompat.checkSelfPermission(
                context, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED;
            
            if (hasPermission) {
                // Permission already granted
                result.success(true);
                return;
            }
            
            // If we have an activity binding, we can request permission
            if (activityPluginBinding != null && activityPluginBinding.getActivity() != null) {
                // Request permission using ActivityCompat
                ActivityCompat.requestPermissions(
                    activityPluginBinding.getActivity(),
                    new String[]{Manifest.permission.READ_SMS},
                    1001 // Request code for SMS permission
                );
                
                // Note: We cannot immediately return the result here as permission request
                // is asynchronous. The permission_handler plugin handles this properly.
                // This method is mainly for compatibility and logging.
                result.success(false);
            } else {
                // No activity available, cannot request permission
                result.error(
                    "NO_ACTIVITY", 
                    "No activity available to request permission", 
                    null
                );
            }
        } catch (Exception e) {
            result.error(
                "PERMISSION_REQUEST_ERROR", 
                "Error requesting SMS permission: " + e.getMessage(), 
                null
            );
        }
    }
    
    /**
     * Retrieves conversations from SMS database with pagination support
     * 
     * This method extracts conversation data from the SMS database and sorts them by date.
     * It supports dynamic limiting for better performance - you can specify how many
     * conversations to retrieve (e.g., first 10) without loading all conversations.
     * 
     * The method uses LIMIT and OFFSET at the database level for optimal performance.
     * 
     * @param limit Maximum number of conversations to retrieve (0 = all conversations)
     * @param offset Number of conversations to skip (for pagination)
     * @param result Flutter result callback to return the conversation list or error
     */
    private void getConversations(int limit, int offset, Result result) {
        // ===== PERMISSION CHECK =====
        // Verify that the app has READ_SMS permission before accessing SMS data
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_SMS) 
                != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "READ_SMS permission is required", null);
            return;
        }
        
        try {
            // ===== GET ALL CONVERSATION THREAD DATA =====
            // Use conversations URI to get all conversation thread data sorted by latest date
            // Using only commonly available columns that work across different Android devices
            Uri conversationsUri = Uri.parse("content://mms-sms/conversations");
            String[] conversationProjection = {
                "_id",               // Unique identifier for the conversation
                "thread_id",         // Unique identifier for each conversation thread
                "date",              // Date of the latest message in this conversation (more compatible than normalized_date)
                "snippet"            // Preview of the latest message content
            };
            
            // ===== BUILD DYNAMIC SORT ORDER WITH PAGINATION =====
            // Construct sortOrder with LIMIT and OFFSET for database-level pagination
            String sortOrder = "date DESC";
            
            // Add LIMIT and OFFSET for pagination if specified
            if (limit > 0) {
                sortOrder += " LIMIT " + limit;
                if (offset > 0) {
                    sortOrder += " OFFSET " + offset;
                }
            }
            
            Cursor conversationCursor = context.getContentResolver().query(
                conversationsUri, 
                conversationProjection, 
                null, // No WHERE clause - get conversations
                null, // No selection arguments
                sortOrder // Sort with pagination at database level
            );
            
            List<Map<String, Object>> conversationList = new ArrayList<>();
            if (conversationCursor != null) {
                try {
                    // ===== GET ADDRESS FOR EACH THREAD AND BUILD COMPLETE CONVERSATION OBJECT =====
                    // For each conversation thread, get all data including phone number
                    while (conversationCursor.moveToNext()) {
                        // Get thread data from conversations table using safe column access
                        long conversationId = conversationCursor.getLong(
                            conversationCursor.getColumnIndexOrThrow("_id")
                        );
                        long threadId = conversationCursor.getLong(
                            conversationCursor.getColumnIndexOrThrow("thread_id")
                        );
                        long date = conversationCursor.getLong(
                            conversationCursor.getColumnIndexOrThrow("date")
                        );
                        String snippet = conversationCursor.getString(
                            conversationCursor.getColumnIndexOrThrow("snippet")
                        );
                        
                        // Query SMS content provider to get address and latest message body for this thread_id
                        Uri smsUri = Telephony.Sms.CONTENT_URI;
                        String[] smsProjection = {"address", "body", "date"};
                        String selection = "thread_id = ?";
                        String[] selectionArgs = {String.valueOf(threadId)};
                        String smsSortOrder = "date DESC LIMIT 1"; // Get most recent message
                        
                        Cursor smsCursor = context.getContentResolver().query(
                            smsUri, smsProjection, selection, selectionArgs, smsSortOrder
                        );
                        
                        String address = "";
                        String latestMessageBody = "";
                        if (smsCursor != null) {
                            try {
                                if (smsCursor.moveToFirst()) {
                                    address = smsCursor.getString(
                                        smsCursor.getColumnIndexOrThrow("address")
                                    );
                                    latestMessageBody = smsCursor.getString(
                                        smsCursor.getColumnIndexOrThrow("body")
                                    );
                                }
                            } finally {
                                // Always close the SMS cursor to prevent memory leaks
                                smsCursor.close();
                            }
                        }
                        
                        // ===== BUILD COMPLETE CONVERSATION OBJECT =====
                        // Create a map containing all conversation thread data
                        Map<String, Object> conversationMap = new HashMap<>();
                        conversationMap.put("_id", conversationId);          // Conversation identifier
                        conversationMap.put("thread_id", threadId);          // Thread identifier
                        conversationMap.put("address", address != null ? address : ""); // Phone number
                        conversationMap.put("date", date);                   // Latest message date
                        // Use the actual message body as snippet since conversations snippet is often empty for SMS
                        conversationMap.put("snippet", latestMessageBody != null ? latestMessageBody : ""); // Latest message preview
                        
                        // Add complete conversation object to the list
                        conversationList.add(conversationMap);
                    }
                } finally {
                    // Always close the conversation cursor to prevent memory leaks
                    conversationCursor.close();
                }
            }
            
            // Return the list of complete conversation objects sorted by latest message date
            result.success(conversationList);
            
        } catch (Exception e) {
            // ===== ERROR HANDLING =====
            // Catch any unexpected errors and return them to Flutter
            result.error("PHONE_NUMBER_READ_ERROR", "Error reading phone numbers: " + e.getMessage(), null);
        }
    }
    
    /**
     * Retrieves all messages for a specific conversation thread using thread_id
     * This method gets all SMS messages from a specific conversation thread
     * for displaying the full conversation. Using thread_id is more efficient
     * than filtering by address as it directly queries the conversation thread.
     * 
     * Performance benefits:
     * - Uses thread_id for direct conversation access (faster than address filtering)
     * - Single database query instead of filtering all messages
     * - Optimized for conversation-based messaging apps
     * 
     * @param threadId The thread ID of the conversation to retrieve messages for
     * @param result Flutter result callback
     */
    private void getConversationMessages(String threadId, Result result) {
        // ===== PERMISSION CHECK =====
        // Verify that the app has READ_SMS permission before accessing SMS data
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_SMS) 
                != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "READ_SMS permission is required", null);
            return;
        }
        
        // ===== INPUT VALIDATION =====
        // Validate threadId parameter to prevent invalid queries
        if (threadId == null || threadId.isEmpty()) {
            result.error("INVALID_THREAD_ID", "Thread ID cannot be null or empty", null);
            return;
        }
        
        try {
            // ===== OPTIMIZED SMS QUERY USING THREAD_ID =====
            // Use thread_id for direct conversation access - this is more efficient
            // than filtering by address as it directly targets the conversation thread
            Uri smsUri = Telephony.Sms.CONTENT_URI;
            String[] projection = {
                Telephony.Sms._ID,           // Message unique identifier
                Telephony.Sms.ADDRESS,       // Phone number/address
                Telephony.Sms.BODY,          // Message content
                Telephony.Sms.DATE,          // Message received date
                Telephony.Sms.DATE_SENT,     // Message sent date
                Telephony.Sms.TYPE,          // Message type (inbox/sent)
                Telephony.Sms.READ,          // Read status
                Telephony.Sms.THREAD_ID      // Thread identifier for verification
            };
            
            // ===== EFFICIENT THREAD-BASED SELECTION =====
            // Filter by thread_id for optimal performance - this directly queries
            // the conversation thread without scanning all messages
            String selection = Telephony.Sms.THREAD_ID + " = ?";
            String[] selectionArgs = {threadId};
            
            // ===== CHRONOLOGICAL SORTING =====
            // Sort by date ascending for proper conversation flow (oldest to newest)
            String sortOrder = Telephony.Sms.DATE + " ASC";
            
            // ===== EXECUTE OPTIMIZED QUERY =====
            // Perform the database query with thread_id filtering
            Cursor cursor = context.getContentResolver().query(
                smsUri, 
                projection, 
                selection, 
                selectionArgs, 
                sortOrder
            );
            
            List<Map<String, Object>> messageList = new ArrayList<>();
            if (cursor != null) {
                try {
                    // ===== PROCESS QUERY RESULTS =====
                    // Iterate through cursor to build message objects
                    while (cursor.moveToNext()) {
                        Map<String, Object> messageMap = new HashMap<>();
                        
                        // Extract all message data with safe column access
                        messageMap.put("id", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms._ID)));
                        messageMap.put("address", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)));
                        messageMap.put("body", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY)));
                        messageMap.put("date", cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)));
                        messageMap.put("dateSent", cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE_SENT)));
                        messageMap.put("type", cursor.getInt(cursor.getColumnIndexOrThrow(Telephony.Sms.TYPE)));
                        messageMap.put("read", cursor.getInt(cursor.getColumnIndexOrThrow(Telephony.Sms.READ)));
                        messageMap.put("threadId", cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms.THREAD_ID)));
                        
                        // Add complete message object to the list
                        messageList.add(messageMap);
                    }
                } finally {
                    // ===== RESOURCE CLEANUP =====
                    // Always close cursor to prevent memory leaks
                    cursor.close();
                }
            }
            
            // ===== RETURN OPTIMIZED RESULTS =====
            // Return the list of messages sorted chronologically for conversation display
            result.success(messageList);
            
        } catch (Exception e) {
            // ===== ERROR HANDLING =====
            // Catch any unexpected errors and return them to Flutter
            result.error("CONVERSATION_MESSAGES_ERROR", "Error reading conversation messages: " + e.getMessage(), null);
        }
    }
    
    /**
     * Retrieves all messages for a specific phone number/address (Legacy method)
     * This method is kept for backward compatibility but is less efficient
     * than using thread_id. Consider using getConversationMessages with thread_id instead.
     * 
     * @param address Phone number or address to get messages for
     * @param result Flutter result callback
     */
    private void getMessagesByAddress(String address, Result result) {
        // Check if READ_SMS permission is granted
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_SMS) 
                != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "READ_SMS permission is required", null);
            return;
        }
        
        if (address == null || address.isEmpty()) {
            result.error("INVALID_ADDRESS", "Address cannot be null or empty", null);
            return;
        }
        
        try {
            List<Map<String, Object>> messageList = new ArrayList<>();
            
            // Query SMS messages for specific address
            Uri uri = Telephony.Sms.CONTENT_URI;
            String[] projection = {
                Telephony.Sms._ID,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
                Telephony.Sms.DATE_SENT,
                Telephony.Sms.TYPE,
                Telephony.Sms.READ
            };
            
            String selection = Telephony.Sms.ADDRESS + " = ?";
            String[] selectionArgs = {address};
            String sortOrder = Telephony.Sms.DATE + " ASC"; // Chronological order for conversation
            
            Cursor cursor = context.getContentResolver().query(
                uri, projection, selection, selectionArgs, sortOrder
            );
            
            if (cursor != null) {
                try {
                    while (cursor.moveToNext()) {
                        Map<String, Object> smsMap = new HashMap<>();
                        smsMap.put("id", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms._ID)));
                        smsMap.put("address", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)));
                        smsMap.put("body", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY)));
                        smsMap.put("date", cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)));
                        smsMap.put("dateSent", cursor.getLong(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE_SENT)));
                        smsMap.put("type", cursor.getInt(cursor.getColumnIndexOrThrow(Telephony.Sms.TYPE)));
                        smsMap.put("read", cursor.getInt(cursor.getColumnIndexOrThrow(Telephony.Sms.READ)));
                        
                        messageList.add(smsMap);
                    }
                } finally {
                    cursor.close();
                }
            }
            
            result.success(messageList);
            
        } catch (Exception e) {
            result.error("CONVERSATION_MESSAGES_ERROR", "Error reading conversation messages: " + e.getMessage(), null);
        }
    }
}
