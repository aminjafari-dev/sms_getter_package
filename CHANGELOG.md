# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added
- Initial release of SMS Getter Package
- SMS message reading functionality with `getAllSms()` method
- Conversation thread support with `getConversations()` method
- Pagination support for conversations with `limit` and `offset` parameters
- Thread-based message retrieval with `getConversationMessages()` method
- Address-based message filtering with `getSmsByAddress()` method
- Permission checking with `checkPermission()` method
- Permission requesting with `requestPermission()` method
- Comprehensive error handling with `SmsException` class
- Complete Android native implementation with Java and Kotlin support
- Extensive documentation and usage examples
- Example app demonstrating all features
- Unit tests for all public methods
- MIT license

### Features
- **SMS Reading**: Read all SMS messages from Android device
- **Conversation Management**: Get conversation threads with pagination
- **Performance Optimized**: Database-level pagination for large datasets
- **Thread-based Access**: Efficient conversation message retrieval
- **Permission Handling**: Built-in permission checking and requesting
- **Error Handling**: Structured error handling with custom exceptions
- **Cross-platform Ready**: Prepared for future platform support

### Technical Details
- Minimum Android SDK version: 16
- Flutter SDK version: ^3.8.1
- Method channel communication with native Android code
- Support for both new embedding API and legacy plugin registration
- Comprehensive Java and Kotlin implementations
- Full test coverage with mocked platform calls

### Documentation
- Complete README with installation and usage instructions
- API reference with method signatures and examples
- Example app with all features demonstrated
- Troubleshooting guide for common issues
- Privacy notice and security considerations

## [Unreleased]

### Planned Features
- iOS support (if Apple allows SMS reading in future iOS versions)
- Web support (if browser APIs become available)
- Windows/macOS/Linux support (if platform APIs become available)
- Enhanced error handling with more specific error codes
- Performance improvements for very large SMS databases
- Contact name resolution integration
- Message filtering and search capabilities
- Export functionality for SMS data
- Backup and restore features

### Potential Improvements
- Add support for MMS messages
- Implement message categorization
- Add support for message threading
- Implement message encryption/decryption
- Add support for message scheduling
- Implement message templates
- Add support for message forwarding
- Implement message archiving
