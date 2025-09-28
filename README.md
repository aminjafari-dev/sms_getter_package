# SMS Getter Package

A Flutter plugin for reading SMS messages from Android devices with conversation support and pagination.

## Features

- 📱 **Read SMS Messages**: Retrieve all SMS messages from the device
- 💬 **Conversation Support**: Get conversation threads with pagination
- 🔍 **Filter by Address**: Get messages for specific phone numbers
- ⚡ **Performance Optimized**: Database-level pagination for large datasets
- 🔐 **Permission Handling**: Built-in permission checking and requesting
- 📊 **Thread-based Access**: Efficient conversation message retrieval using thread IDs

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sms_getter_package:
    git:
      url: https://github.com/yourusername/sms_getter_package.git
```

Or if published to pub.dev:

```yaml
dependencies:
  sms_getter_package: ^1.0.0
```

## Android Setup

### Permissions

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

### Minimum SDK Version

Ensure your `android/app/build.gradle` has a minimum SDK version of 16 or higher:

```gradle
android {
    defaultConfig {
        minSdkVersion 16
    }
}
```

## Usage

### Basic Usage

```dart
import 'package:sms_getter_package/sms_getter_package.dart';

// Check if SMS permission is granted
final hasPermission = await SmsGetterPackage.checkPermission();

if (hasPermission) {
  // Read all SMS messages
  final messages = await SmsGetterPackage.getAllSms();
  
  for (var message in messages) {
    print('From: ${message['address']}');
    print('Message: ${message['body']}');
    print('Date: ${DateTime.fromMillisecondsSinceEpoch(message['date'])}');
  }
}
```

### Permission Handling

```dart
import 'package:permission_handler/permission_handler.dart';

// Request SMS permission
final status = await Permission.sms.request();

if (status.isGranted) {
  // Permission granted, proceed with SMS operations
  final messages = await SmsGetterPackage.getAllSms();
} else {
  // Handle permission denial
  print('SMS permission denied');
}
```

### Get Conversations with Pagination

```dart
// Get first 20 conversations
final conversations = await SmsGetterPackage.getConversations(
  limit: 20,
  offset: 0,
);

// Get next 20 conversations (pagination)
final nextConversations = await SmsGetterPackage.getConversations(
  limit: 20,
  offset: 20,
);

for (var conversation in conversations) {
  print('Thread ID: ${conversation['thread_id']}');
  print('Address: ${conversation['address']}');
  print('Latest Message: ${conversation['snippet']}');
  print('Date: ${DateTime.fromMillisecondsSinceEpoch(conversation['date'])}');
}
```

### Get Messages for a Specific Conversation

```dart
// Get all messages for a specific conversation thread
final messages = await SmsGetterPackage.getConversationMessages('123');

for (var message in messages) {
  print('From: ${message['address']}');
  print('Message: ${message['body']}');
  print('Type: ${message['type'] == 1 ? 'Received' : 'Sent'}');
}
```

### Filter Messages by Address

```dart
// Get all messages from/to a specific phone number
final messages = await SmsGetterPackage.getSmsByAddress('+1234567890');

for (var message in messages) {
  print('Message: ${message['body']}');
  print('Date: ${DateTime.fromMillisecondsSinceEpoch(message['date'])}');
}
```

## API Reference

### Methods

#### `getAllSms()`
Retrieves all SMS messages from the device.

**Returns:** `Future<List<Map<String, dynamic>>>`

**Message Map Structure:**
```dart
{
  'id': String,           // Unique message identifier
  'address': String,      // Phone number/address
  'body': String,         // Message content
  'date': int,           // Message received date (timestamp)
  'dateSent': int,       // Message sent date (timestamp)
  'type': int,           // Message type (1 = received, 2 = sent)
  'read': int,           // Read status (0 = unread, 1 = read)
}
```

#### `getConversations({int limit = 0, int offset = 0})`
Retrieves conversation threads with pagination support.

**Parameters:**
- `limit`: Maximum number of conversations to retrieve (0 = all conversations)
- `offset`: Number of conversations to skip (for pagination)

**Returns:** `Future<List<Map<String, dynamic>>>`

**Conversation Map Structure:**
```dart
{
  '_id': int,            // Conversation identifier
  'thread_id': int,      // Thread identifier
  'address': String,     // Phone number/address
  'date': int,          // Latest message date (timestamp)
  'snippet': String,    // Preview of the latest message
}
```

#### `getConversationMessages(String threadId)`
Retrieves all messages for a specific conversation thread.

**Parameters:**
- `threadId`: The thread ID of the conversation

**Returns:** `Future<List<Map<String, dynamic>>>`

#### `getSmsByAddress(String address)`
Retrieves SMS messages for a specific phone number/address.

**Parameters:**
- `address`: The phone number or address to filter messages by

**Returns:** `Future<List<Map<String, dynamic>>>`

#### `checkPermission()`
Checks if READ_SMS permission is granted.

**Returns:** `Future<bool>`

#### `requestPermission()`
Requests READ_SMS permission from the user.

**Returns:** `Future<bool>`

### Error Handling

The plugin throws `SmsException` for SMS-related errors:

```dart
try {
  final messages = await SmsGetterPackage.getAllSms();
} on SmsException catch (e) {
  switch (e.code) {
    case 'PERMISSION_DENIED':
      print('SMS permission is required');
      break;
    case 'SMS_READ_ERROR':
      print('Error reading SMS: ${e.message}');
      break;
    default:
      print('Unknown error: ${e.message}');
  }
}
```

## Example App

Check out the `example/` directory for a complete example app demonstrating all features of the SMS Getter Package.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## Performance Considerations

- **Pagination**: Use `getConversations()` with `limit` and `offset` parameters for better performance with large numbers of conversations
- **Thread-based Access**: Use `getConversationMessages()` with thread IDs instead of filtering by address for better performance
- **Permission Caching**: Check permission status before making multiple SMS operations

## Platform Support

- ✅ **Android**: Full support with all features
- ❌ **iOS**: Not supported (iOS doesn't allow reading SMS messages)
- ❌ **Web**: Not supported
- ❌ **Windows/macOS/Linux**: Not supported

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Privacy Notice

This plugin reads SMS messages from the device's SMS database. Please ensure you:

- Only request SMS permission when necessary
- Handle SMS data responsibly and securely
- Comply with local privacy laws and regulations
- Inform users about SMS data usage in your app's privacy policy

## Troubleshooting

### Common Issues

1. **Permission Denied Error**
   - Ensure `READ_SMS` permission is added to AndroidManifest.xml
   - Request permission before calling SMS methods
   - Check if permission is granted using `checkPermission()`

2. **No Messages Returned**
   - Verify the device has SMS messages
   - Check if permission is granted
   - Ensure the app is running on a physical device (not emulator)

3. **Build Errors**
   - Ensure minimum SDK version is 16 or higher
   - Clean and rebuild the project
   - Check for conflicting dependencies

### Getting Help

- Check the [example app](example/) for usage examples
- Open an [issue](https://github.com/yourusername/sms_getter_package/issues) for bug reports
- Create a [discussion](https://github.com/yourusername/sms_getter_package/discussions) for questions

## Changelog

### 1.0.0
- Initial release
- SMS message reading functionality
- Conversation thread support with pagination
- Permission handling
- Thread-based message retrieval
- Comprehensive error handling