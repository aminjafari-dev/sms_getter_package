import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_getter_package/sms_getter_package.dart';

/// Example app demonstrating SMS Getter Package functionality
///
/// This app shows how to:
/// - Check and request SMS permissions
/// - Read all SMS messages
/// - Get conversation threads with pagination
/// - Display conversation messages
/// - Handle errors gracefully
///
/// Usage:
/// 1. Run the app on an Android device
/// 2. Grant SMS permission when prompted
/// 3. Explore the different SMS reading features
void main() {
  runApp(const SmsGetterExampleApp());
}

/// Main application widget
///
/// This widget sets up the MaterialApp with the SMS example home page.
/// It provides a clean interface for demonstrating all SMS reading features.
class SmsGetterExampleApp extends StatelessWidget {
  const SmsGetterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Getter Package Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SmsExampleHomePage(),
    );
  }
}

/// Home page for SMS example functionality
///
/// This page provides buttons to test different SMS reading features:
/// - Check permission status
/// - Request SMS permission
/// - Read all SMS messages
/// - Get conversation threads
/// - Display results in a scrollable list
class SmsExampleHomePage extends StatefulWidget {
  const SmsExampleHomePage({super.key});

  @override
  State<SmsExampleHomePage> createState() => _SmsExampleHomePageState();
}

class _SmsExampleHomePageState extends State<SmsExampleHomePage> {
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = false;
  String _statusMessage = 'Ready to test SMS functionality';

  /// Check if SMS permission is granted
  ///
  /// This method demonstrates how to check the current permission status
  /// before attempting to read SMS messages.
  Future<void> _checkPermission() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking permission...';
    });

    try {
      final hasPermission = await SmsGetterPackage.checkPermission();
      setState(() {
        _statusMessage = hasPermission
            ? 'SMS permission is granted'
            : 'SMS permission is not granted';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking permission: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Request SMS permission from the user
  ///
  /// This method demonstrates how to request SMS permission using
  /// the permission_handler package for better user experience.
  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting permission...';
    });

    try {
      // Use permission_handler for better permission handling
      final status = await Permission.sms.request();

      if (status.isGranted) {
        setState(() {
          _statusMessage = 'SMS permission granted successfully';
        });
      } else if (status.isDenied) {
        setState(() {
          _statusMessage = 'SMS permission denied by user';
        });
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _statusMessage =
              'SMS permission permanently denied. Please enable in settings.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error requesting permission: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Read all SMS messages from the device
  ///
  /// This method demonstrates how to retrieve all SMS messages
  /// and display them in a list format.
  Future<void> _getAllSms() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Reading SMS messages...';
      _messages.clear();
    });

    try {
      final messages = await SmsGetterPackage.getAllSms();
      setState(() {
        _messages = messages;
        _statusMessage = 'Found ${messages.length} SMS messages';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error reading SMS: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get conversation threads with pagination
  ///
  /// This method demonstrates how to retrieve conversation threads
  /// with pagination support for better performance.
  Future<void> _getConversations() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Reading conversations...';
      _conversations.clear();
    });

    try {
      // Get first 20 conversations as an example
      final conversations = await SmsGetterPackage.getConversations(
        limit: 20,
        offset: 0,
      );
      setState(() {
        _conversations = conversations;
        _statusMessage = 'Found ${conversations.length} conversations';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error reading conversations: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get messages for a specific conversation
  ///
  /// This method demonstrates how to retrieve messages for a specific
  /// conversation thread using the thread ID.
  Future<void> _getConversationMessages(String threadId) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Reading conversation messages...';
      _messages.clear();
    });

    try {
      final messages = await SmsGetterPackage.getConversationMessages(threadId);
      setState(() {
        _messages = messages;
        _statusMessage = 'Found ${messages.length} messages in conversation';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error reading conversation messages: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Format timestamp to readable date string
  ///
  /// This helper method converts Unix timestamps to readable date strings
  /// for displaying message dates in the UI.
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Getter Package Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Permission buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkPermission,
                    child: const Text('Check Permission'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestPermission,
                    child: const Text('Request Permission'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SMS reading buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getAllSms,
                    child: const Text('Get All SMS'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getConversations,
                    child: const Text('Get Conversations'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Results display
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  /// Build the results list widget
  ///
  /// This method creates a scrollable list to display either SMS messages
  /// or conversation threads based on the current data.
  Widget _buildResultsList() {
    if (_conversations.isNotEmpty) {
      return _buildConversationsList();
    } else if (_messages.isNotEmpty) {
      return _buildMessagesList();
    } else {
      return const Center(
        child: Text(
          'No data to display. Try reading SMS or conversations.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
  }

  /// Build conversations list widget
  ///
  /// This method creates a list of conversation threads with clickable
  /// items that allow viewing individual conversation messages.
  Widget _buildConversationsList() {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return Card(
          child: ListTile(
            title: Text(
              conversation['address'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conversation['snippet'] ?? 'No preview'),
                Text(
                  _formatDate(conversation['date'] ?? 0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () =>
                _getConversationMessages(conversation['thread_id'].toString()),
          ),
        );
      },
    );
  }

  /// Build messages list widget
  ///
  /// This method creates a list of SMS messages with detailed information
  /// including sender, content, and timestamp.
  Widget _buildMessagesList() {
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isReceived = message['type'] == 1;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isReceived ? Colors.blue : Colors.green,
              child: Icon(
                isReceived ? Icons.inbox : Icons.outbox,
                color: Colors.white,
              ),
            ),
            title: Text(
              message['address'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message['body'] ?? 'No content'),
                Text(
                  _formatDate(message['date'] ?? 0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Text(
              isReceived ? 'Received' : 'Sent',
              style: TextStyle(
                color: isReceived ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
