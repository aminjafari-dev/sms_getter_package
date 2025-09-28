import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sms_getter_package/sms_getter_package.dart';

/// Test suite for SMS Getter Package
///
/// This test suite verifies the functionality of the SMS Getter Package
/// including method channel communication, error handling, and data parsing.
///
/// Note: These tests mock the native platform calls since we can't
/// actually read SMS messages in a test environment.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SmsGetterPackage', () {
    const MethodChannel channel = MethodChannel('sms_getter_package');

    setUp(() {
      // Reset method channel before each test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    tearDown(() {
      // Clean up method channel after each test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    group('getAllSms', () {
      test('should return list of SMS messages when successful', () async {
        // Arrange: Mock successful SMS reading response
        final mockMessages = [
          {
            'id': '1',
            'address': '+1234567890',
            'body': 'Test message 1',
            'date': 1640995200000, // 2022-01-01 00:00:00
            'dateSent': 1640995200000,
            'type': 1, // Received
            'read': 1, // Read
          },
          {
            'id': '2',
            'address': '+0987654321',
            'body': 'Test message 2',
            'date': 1640995260000, // 2022-01-01 00:01:00
            'dateSent': 1640995260000,
            'type': 2, // Sent
            'read': 1, // Read
          },
        ];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getAllSms') {
                return mockMessages;
              }
              return null;
            });

        // Act: Call getAllSms method
        final result = await SmsGetterPackage.getAllSms();

        // Assert: Verify the result
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result[0]['address'], equals('+1234567890'));
        expect(result[0]['body'], equals('Test message 1'));
        expect(result[0]['type'], equals(1));
        expect(result[1]['address'], equals('+0987654321'));
        expect(result[1]['body'], equals('Test message 2'));
        expect(result[1]['type'], equals(2));
      });

      test('should throw SmsException when permission is denied', () async {
        // Arrange: Mock permission denied error
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getAllSms') {
                throw PlatformException(
                  code: 'PERMISSION_DENIED',
                  message: 'READ_SMS permission is required',
                );
              }
              return null;
            });

        // Act & Assert: Verify exception is thrown
        expect(
          () => SmsGetterPackage.getAllSms(),
          throwsA(isA<SmsException>()),
        );

        try {
          await SmsGetterPackage.getAllSms();
        } on SmsException catch (e) {
          expect(e.code, equals('PERMISSION_DENIED'));
          expect(e.message, equals('READ_SMS permission is required'));
        }
      });

      test('should throw SmsException when SMS reading fails', () async {
        // Arrange: Mock SMS reading error
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getAllSms') {
                throw PlatformException(
                  code: 'SMS_READ_ERROR',
                  message: 'Error reading SMS messages: Database error',
                );
              }
              return null;
            });

        // Act & Assert: Verify exception is thrown
        expect(
          () => SmsGetterPackage.getAllSms(),
          throwsA(isA<SmsException>()),
        );

        try {
          await SmsGetterPackage.getAllSms();
        } on SmsException catch (e) {
          expect(e.code, equals('SMS_READ_ERROR'));
          expect(
            e.message,
            equals('Error reading SMS messages: Database error'),
          );
        }
      });
    });

    group('getConversations', () {
      test('should return list of conversations with pagination', () async {
        // Arrange: Mock successful conversations response
        final mockConversations = [
          {
            '_id': 1,
            'thread_id': 123,
            'address': '+1234567890',
            'date': 1640995200000,
            'snippet': 'Latest message preview',
          },
          {
            '_id': 2,
            'thread_id': 124,
            'address': '+0987654321',
            'date': 1640995260000,
            'snippet': 'Another message preview',
          },
        ];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getConversations') {
                expect(methodCall.arguments['limit'], equals(10));
                expect(methodCall.arguments['offset'], equals(0));
                return mockConversations;
              }
              return null;
            });

        // Act: Call getConversations method with pagination
        final result = await SmsGetterPackage.getConversations(
          limit: 10,
          offset: 0,
        );

        // Assert: Verify the result
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result[0]['thread_id'], equals(123));
        expect(result[0]['address'], equals('+1234567890'));
        expect(result[0]['snippet'], equals('Latest message preview'));
        expect(result[1]['thread_id'], equals(124));
        expect(result[1]['address'], equals('+0987654321'));
        expect(result[1]['snippet'], equals('Another message preview'));
      });

      test('should use default pagination parameters', () async {
        // Arrange: Mock conversations response
        final mockConversations = <Map<String, dynamic>>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getConversations') {
                expect(methodCall.arguments['limit'], equals(0));
                expect(methodCall.arguments['offset'], equals(0));
                return mockConversations;
              }
              return null;
            });

        // Act: Call getConversations method without parameters
        final result = await SmsGetterPackage.getConversations();

        // Assert: Verify default parameters were used
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(0));
      });
    });

    group('getConversationMessages', () {
      test('should return messages for specific conversation thread', () async {
        // Arrange: Mock conversation messages response
        final mockMessages = [
          {
            'id': '1',
            'address': '+1234567890',
            'body': 'First message',
            'date': 1640995200000,
            'dateSent': 1640995200000,
            'type': 1,
            'read': 1,
            'threadId': 123,
          },
          {
            'id': '2',
            'address': '+1234567890',
            'body': 'Second message',
            'date': 1640995260000,
            'dateSent': 1640995260000,
            'type': 2,
            'read': 1,
            'threadId': 123,
          },
        ];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getConversationMessages') {
                expect(methodCall.arguments['threadId'], equals('123'));
                return mockMessages;
              }
              return null;
            });

        // Act: Call getConversationMessages method
        final result = await SmsGetterPackage.getConversationMessages('123');

        // Assert: Verify the result
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result[0]['threadId'], equals(123));
        expect(result[0]['body'], equals('First message'));
        expect(result[1]['threadId'], equals(123));
        expect(result[1]['body'], equals('Second message'));
      });
    });

    group('getSmsByAddress', () {
      test('should return messages for specific address', () async {
        // Arrange: Mock SMS by address response
        final mockMessages = [
          {
            'id': '1',
            'address': '+1234567890',
            'body': 'Message from specific address',
            'date': 1640995200000,
            'dateSent': 1640995200000,
            'type': 1,
            'read': 1,
          },
        ];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getSmsByAddress') {
                expect(methodCall.arguments['address'], equals('+1234567890'));
                return mockMessages;
              }
              return null;
            });

        // Act: Call getSmsByAddress method
        final result = await SmsGetterPackage.getSmsByAddress('+1234567890');

        // Assert: Verify the result
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(1));
        expect(result[0]['address'], equals('+1234567890'));
        expect(result[0]['body'], equals('Message from specific address'));
      });
    });

    group('checkPermission', () {
      test('should return true when permission is granted', () async {
        // Arrange: Mock permission granted response
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'checkPermission') {
                return true;
              }
              return null;
            });

        // Act: Call checkPermission method
        final result = await SmsGetterPackage.checkPermission();

        // Assert: Verify the result
        expect(result, isTrue);
      });

      test('should return false when permission is not granted', () async {
        // Arrange: Mock permission not granted response
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'checkPermission') {
                return false;
              }
              return null;
            });

        // Act: Call checkPermission method
        final result = await SmsGetterPackage.checkPermission();

        // Assert: Verify the result
        expect(result, isFalse);
      });
    });

    group('requestPermission', () {
      test('should return true when permission is granted', () async {
        // Arrange: Mock permission granted response
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'requestPermission') {
                return true;
              }
              return null;
            });

        // Act: Call requestPermission method
        final result = await SmsGetterPackage.requestPermission();

        // Assert: Verify the result
        expect(result, isTrue);
      });

      test('should return false when permission is denied', () async {
        // Arrange: Mock permission denied response
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'requestPermission') {
                return false;
              }
              return null;
            });

        // Act: Call requestPermission method
        final result = await SmsGetterPackage.requestPermission();

        // Assert: Verify the result
        expect(result, isFalse);
      });
    });
  });

  group('SmsException', () {
    test('should create exception with code and message', () {
      // Arrange & Act
      const exception = SmsException('TEST_ERROR', 'Test error message');

      // Assert
      expect(exception.code, equals('TEST_ERROR'));
      expect(exception.message, equals('Test error message'));
    });

    test('should return proper string representation', () {
      // Arrange & Act
      const exception = SmsException('TEST_ERROR', 'Test error message');

      // Assert
      expect(
        exception.toString(),
        equals('SmsException(TEST_ERROR): Test error message'),
      );
    });
  });
}
