/// SMS Getter Package
///
/// A Flutter plugin for reading SMS messages from Android devices.
/// This package provides functionality to:
/// - Read all SMS messages
/// - Get SMS messages by address/phone number
/// - Retrieve conversation threads
/// - Get messages for specific conversations
/// - Check and request SMS permissions
///
/// Usage example:
/// ```dart
/// final smsPlugin = SmsGetterPackage();
/// final hasPermission = await smsPlugin.checkPermission();
/// if (hasPermission) {
///   final messages = await smsPlugin.getAllSms();
/// }
/// ```
library sms_getter_package;

import 'dart:async';
import 'package:flutter/services.dart';

/// Main plugin class for SMS reading functionality
///
/// This class provides methods to interact with the native Android SMS database
/// through method channels. It handles all SMS-related operations including
/// reading messages, managing conversations, and permission handling.
///
/// Example usage:
/// ```dart
/// final smsPlugin = SmsGetterPackage();
///
/// // Check if permission is granted
/// final hasPermission = await smsPlugin.checkPermission();
///
/// // Request permission if needed
/// if (!hasPermission) {
///   await smsPlugin.requestPermission();
/// }
///
/// // Get all SMS messages
/// final messages = await smsPlugin.getAllSms();
///
/// // Get conversations with pagination
/// final conversations = await smsPlugin.getConversations(limit: 10, offset: 0);
/// ```
class SmsGetterPackage {
  /// Method channel for communication with native Android code
  static const MethodChannel _channel = MethodChannel('sms_getter_package');

  /// Retrieves all SMS messages from the device
  ///
  /// This method reads all SMS messages from the device's SMS database
  /// and returns them as a list of maps containing SMS details.
  ///
  /// Returns a Future<List<Map<String, dynamic>>> containing SMS messages.
  /// Each message map contains:
  /// - id: String - Unique message identifier
  /// - address: String - Phone number/address
  /// - body: String - Message content
  /// - date: int - Message received date (timestamp)
  /// - dateSent: int - Message sent date (timestamp)
  /// - type: int - Message type (1 = received, 2 = sent)
  /// - read: int - Read status (0 = unread, 1 = read)
  ///
  /// Throws PlatformException if permission is denied or SMS reading fails.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final messages = await smsPlugin.getAllSms();
  ///   for (var message in messages) {
  ///     print('From: ${message['address']}');
  ///     print('Message: ${message['body']}');
  ///     print('Date: ${DateTime.fromMillisecondsSinceEpoch(message['date'])}');
  ///   }
  /// } catch (e) {
  ///   print('Error reading SMS: $e');
  /// }
  /// ```
  static Future<List<Map<String, dynamic>>> getAllSms() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getAllSms');
      return result.cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      throw SmsException(e.code, e.message ?? 'Unknown error occurred');
    }
  }

  /// Retrieves SMS messages for a specific phone number/address
  ///
  /// This method filters SMS messages by the provided address/phone number
  /// and returns all messages from/to that address.
  ///
  /// [address] - The phone number or address to filter messages by
  ///
  /// Returns a Future<List<Map<String, dynamic>>> containing filtered SMS messages.
  ///
  /// Throws PlatformException if permission is denied or SMS reading fails.
  ///
  /// Example:
  /// ```dart
  /// final messages = await smsPlugin.getSmsByAddress('+1234567890');
  /// ```
  static Future<List<Map<String, dynamic>>> getSmsByAddress(
    String address,
  ) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getSmsByAddress',
        {'address': address},
      );
      return result.cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      throw SmsException(e.code, e.message ?? 'Unknown error occurred');
    }
  }

  /// Retrieves conversation threads with pagination support
  ///
  /// This method gets conversation threads from the SMS database and supports
  /// pagination for better performance when dealing with large numbers of conversations.
  ///
  /// [limit] - Maximum number of conversations to retrieve (0 = all conversations)
  /// [offset] - Number of conversations to skip (for pagination)
  ///
  /// Returns a Future<List<Map<String, dynamic>>> containing conversation data.
  /// Each conversation map contains:
  /// - _id: int - Conversation identifier
  /// - thread_id: int - Thread identifier
  /// - address: String - Phone number/address
  /// - date: int - Latest message date (timestamp)
  /// - snippet: String - Preview of the latest message
  ///
  /// Example:
  /// ```dart
  /// // Get first 10 conversations
  /// final conversations = await smsPlugin.getConversations(limit: 10, offset: 0);
  ///
  /// // Get next 10 conversations (pagination)
  /// final nextConversations = await smsPlugin.getConversations(limit: 10, offset: 10);
  /// ```
  static Future<List<Map<String, dynamic>>> getConversations({
    int limit = 0,
    int offset = 0,
  }) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getConversations',
        {'limit': limit, 'offset': offset},
      );
      return result.cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      throw SmsException(e.code, e.message ?? 'Unknown error occurred');
    }
  }

  /// Retrieves all messages for a specific conversation thread
  ///
  /// This method gets all SMS messages from a specific conversation thread
  /// using the thread_id for optimal performance.
  ///
  /// [threadId] - The thread ID of the conversation to retrieve messages for
  ///
  /// Returns a Future<List<Map<String, dynamic>>> containing conversation messages.
  /// Messages are sorted chronologically (oldest to newest).
  ///
  /// Example:
  /// ```dart
  /// final messages = await smsPlugin.getConversationMessages('123');
  /// ```
  static Future<List<Map<String, dynamic>>> getConversationMessages(
    String threadId,
  ) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getConversationMessages',
        {'threadId': threadId},
      );
      return result.cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      throw SmsException(e.code, e.message ?? 'Unknown error occurred');
    }
  }

  /// Retrieves messages by address (legacy method)
  ///
  /// This method is kept for backward compatibility but is less efficient
  /// than using getConversationMessages with thread_id.
  ///
  /// [address] - Phone number or address to get messages for
  ///
  /// Returns a Future<List<Map<String, dynamic>>> containing messages.
  static Future<List<Map<String, dynamic>>> getMessagesByAddress(
    String address,
  ) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getMessagesByAddress',
        {'address': address},
      );
      return result.cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      throw SmsException(e.code, e.message ?? 'Unknown error occurred');
    }
  }

  /// Checks if READ_SMS permission is granted
  ///
  /// This method verifies if the application has the necessary permission
  /// to read SMS messages from the device.
  ///
  /// Returns a Future<bool> indicating permission status.
  ///
  /// Example:
  /// ```dart
  /// final hasPermission = await smsPlugin.checkPermission();
  /// if (hasPermission) {
  ///   // Permission granted, proceed with SMS operations
  /// } else {
  ///   // Permission not granted, request it
  /// }
  /// ```
  static Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkPermission');
      return result;
    } on PlatformException catch (e) {
      throw SmsException(e.code, e.message ?? 'Unknown error occurred');
    }
  }

  /// Requests READ_SMS permission from the user
  ///
  /// This method shows the system permission dialog to request SMS permission.
  /// Note: This method is primarily for compatibility. The permission_handler
  /// plugin handles the actual permission request flow in Flutter.
  ///
  /// Returns a Future<bool> indicating if permission was granted.
  ///
  /// Example:
  /// ```dart
  /// final granted = await smsPlugin.requestPermission();
  /// if (granted) {
  ///   // Permission granted, proceed with SMS operations
  /// } else {
  ///   // Permission denied, handle accordingly
  /// }
  /// ```
  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestPermission');
      return result;
    } on PlatformException catch (e) {
      throw SmsException(e.code, e.message ?? 'Unknown error occurred');
    }
  }
}

/// Custom exception class for SMS-related errors
///
/// This class provides structured error handling for SMS operations,
/// including error codes and descriptive messages.
///
/// Example:
/// ```dart
/// try {
///   final messages = await SmsGetterPackage.getAllSms();
/// } on SmsException catch (e) {
///   switch (e.code) {
///     case 'PERMISSION_DENIED':
///       print('SMS permission is required');
///       break;
///     case 'SMS_READ_ERROR':
///       print('Error reading SMS: ${e.message}');
///       break;
///     default:
///       print('Unknown error: ${e.message}');
///   }
/// }
/// ```
class SmsException implements Exception {
  /// Error code identifying the type of error
  final String code;

  /// Human-readable error message
  final String message;

  /// Creates a new SMS exception
  ///
  /// [code] - Error code identifying the type of error
  /// [message] - Human-readable error message
  const SmsException(this.code, this.message);

  @override
  String toString() => 'SmsException($code): $message';
}
