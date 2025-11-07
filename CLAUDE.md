# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter demo project showcasing an advanced file and image picker implementation with support for cropping, resizing, and compression. The project demonstrates a flexible, configurable picker system that uses isolates for performance-intensive operations.

## Development Commands

### Running the App
```bash
flutter run
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/ test/

# Get dependencies
flutter pub get

# Clean build artifacts
flutter clean
```

### Building
```bash
# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Build for web
flutter build web
```

## Architecture Overview

### Core Components

#### 1. AppFilePickerService
The main entry point for file picking operations (`lib/component/picker/app_file_picker_service.dart`). It orchestrates the entire picking flow:
- Provides three specialized methods:
  - `pickImageWithSourceSelection()` - for images only (camera/gallery)
  - `pickFileWithSourceSelection()` - for files only (file system)
  - `pickMediaWithSourceSelection()` - deprecated, kept for backward compatibility
- Source selection (camera, gallery, file system)
- Delegates to specialized pickers based on source type
- Applies post-processing pipeline (crop → resize → compress)

#### 2. Picker Configuration System
All pickers are configured via `PickerConfig` (`lib/component/picker/config/picker_config.dart`):
- `cropper`: Optional image cropping (implements `BaseCropper`)
- `resizer`: Optional image resizing (implements `BaseResizer`)
- `compress`: Optional image compression (implements `BaseCompress`)
- `sourceSelectorFactory`: Custom UI for source selection
- `pickerUIConfig`: UI customization options

#### 3. Processing Pipeline
Image processing follows a strict order in `AppImagePicker`:
1. **Pick** from camera/gallery (runs in isolate)
2. **Crop** (optional, UI-based)
3. **Resize** (optional, runs in isolate)
4. **Compress** (optional, runs in isolate with iterative quality reduction)

#### 4. Isolate-Based Processing
Performance-intensive operations use isolates to avoid blocking the UI thread:
- **Image picking**: `_isolatePickImage` in `app_image_picker.dart:87`
- **Compression**: `ImageCompressor.compressImageInIsolate()` in `image_compressor.dart:58`
- Requires `RootIsolateToken` for platform channel access

#### 5. Source Selection System
Extensible source selection via `SourceSelectorFactory` interface:
- `DefaultSourceSelectorFactory`: Provides dialog or bottom sheet UI
- `CustomSourceSelectorFactory`: Example of custom implementation
- Return `MediaSource` enum: `gallery`, `camera`, or `fileSystem`

### Key Design Patterns

#### Strategy Pattern
- `BaseCropper`, `BaseResizer`, `BaseCompress` define processing interfaces
- Implementations: `FreeCropper`, `ImageResizer`, `ImageCompressor`
- Allows swapping algorithms via configuration

#### Factory Pattern
- `SourceSelectorFactory` creates source selection UI
- `LoggerFactory` creates specialized logger instances

#### Wrapper Pattern
- `XFileWrapper` wraps `XFile` with additional metadata (filename)
- Provides utilities via extensions in `x_file_extension.dart`

### Logging System

The project uses a sophisticated logging architecture (`lib/logger/`):

#### LoggerFactory Loggers
- **Default logger**: `LoggerFactory.createLogger()` - general purpose
- **Network logger**: `LoggerFactory.createNetworkLogger()` - for HTTP/Dio
- **Feature logger**: `LoggerFactory.createFeatureLogger(name)` - scoped to features
- **Performance logger**: `LoggerFactory.createPerformanceLogger()` - timing/metrics

#### Log Outputs
- **Development**: `AppConsoleLogOutput` - formatted console output
- **Production**: `AppCrashlyticsLogOutput` - sends to Firebase Crashlytics
- Configure via `LoggerFactory.enableCrashlytics` and `enableConsoleLogging`

#### Global Logger
Use `logger` from `app_logger_impl.dart` for general logging:
```dart
logger.i('Informational message');
logger.e('Error message', error: e, stackTrace: s);
logger.crash(reason: 'Critical failure', error: e, stackTrace: s);
```

### File Structure

```
lib/
├── component/picker/          # Core picker implementation
│   ├── pick_image/           # Image-specific picker
│   │   ├── compressors/      # Compression strategies
│   │   ├── croppers/         # Cropping strategies
│   │   └── resizers/         # Resizing strategies
│   ├── pick_file/            # File system picker
│   ├── config/               # Configuration classes
│   ├── source_selector/      # Source selection UI factories
│   ├── widgets/              # Reusable picker UI components
│   └── x_file/               # XFile utilities and extensions
├── logger/                    # Logging infrastructure
└── presentation/              # UI screens and demos
```

## Important Implementation Details

### Image Compression
`ImageCompressor` uses iterative compression with quality reduction:
- Starts at `initialQuality` (default: 100)
- Reduces by `qualityStep` (default: 5) each iteration
- Stops when file ≤ `fileLimitMb` OR quality < `minQuality` OR `maxAttempts` reached
- Each compression runs in isolate for performance

### XFile Extensions
Common operations on `XFile` via extensions (`x_file_extension.dart`):
- `sizeInKB`: Get file size in kilobytes
- `getFileSizeFormatted(decimals)`: Human-readable size string
- Use these instead of manual file size calculations

### Context Safety
UI operations check `context.mounted` before use:
```dart
if (!context.mounted) return null;
```
This is critical after async operations to prevent using disposed contexts.

## Configuration Examples

See `lib/presentation/home_screen.dart` for complete configuration examples:

### Basic Picker with Full Pipeline
```dart
final config = PickerConfig(
  cropper: FreeCropper(cropStyle: CropStyle.rectangle),
  compress: ImageCompressor(fileLimitMb: 1),
  resizer: ImageResizer(),
);
```

### Using Specialized Picker Methods
```dart
// For images only (camera/gallery selection)
final imageFile = await AppFilePickerService.pickImageWithSourceSelection(
  context: context,
  config: config,
);

// For files only (file system selection)
final file = await AppFilePickerService.pickFileWithSourceSelection(
  context: context,
  config: config,
);

// Deprecated method (kept for backward compatibility)
final mediaFile = await AppFilePickerService.pickMediaWithSourceSelection(
  context: context,
  config: config,
);
```

### Custom Source Selection UI
```dart
final config = PickerConfig(
  pickerUIConfig: PickerUIConfig.custom(
    sheetTitle: 'Select Source',
    uiType: PickerUiType.customBottomSheet,
    actions: [
      PickerAction(title: 'Gallery', icon: Icon(Icons.photo), source: MediaSource.gallery),
      PickerAction(title: 'Camera', icon: Icon(Icons.camera), source: MediaSource.camera),
    ],
  ),
);
```

### Custom Factory
```dart
final config = PickerConfig(
  sourceSelectorFactory: CustomSourceSelectorFactory(CustomPickerUiType.modalBottomSheet),
);
```

## Dependencies

Key third-party packages:
- `file_picker`: File system access
- `image_picker`: Camera/gallery access
- `image_cropper`: Image cropping UI
- `flutter_image_compress`: Native image compression
- `image`: Dart image manipulation
- `logger`: Structured logging
- `modal_bottom_sheet`: Modal presentations
- `adaptive_dialog`: Cross-platform dialogs

## Testing Notes

When testing picker functionality:
- Mock `ImagePicker` for unit tests
- Consider isolate communication in tests
- Test context safety (mounted checks)
- Verify compression iterations stay within limits