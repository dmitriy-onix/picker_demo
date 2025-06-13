import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';
import 'package:picker_demo/logger/app_logger_impl.dart';
import 'base_cropper.dart';

/// A wrapper for the `image_cropper` package that provides a highly
/// configurable image cropping interface.
class FreeCropper implements BaseCropper {
  /// The visual style of the crop frame (e.g., circle, rectangle).
  final CropStyle cropStyle;

  /// A fixed aspect ratio for the crop frame.
  final CropAspectRatio? aspectRatio;

  /// A list of predefined aspect ratios the user can select from.
  final List<CropAspectRatioPreset> aspectRatioPresets;

  /// Provides advanced, platform-specific UI settings for Android.
  /// If provided, it overrides the simpler settings above.
  final AndroidUiSettings? androidUiSettings;

  /// Provides advanced, platform-specific UI settings for iOS/macOS.
  /// If provided, it overrides the simpler settings above.
  final IOSUiSettings? iOSUiSettings;

  FreeCropper({
    this.cropStyle = CropStyle.rectangle,
    this.aspectRatio,
    this.aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio16x9,
    ],
    this.androidUiSettings,
    this.iOSUiSettings,
  });

  @override
  Future<XFileWrapper?> crop(
    BuildContext context,
    XFileWrapper? wrapperFile,
  ) async {
    if (wrapperFile == null) return null;

    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: wrapperFile.file.path,
        aspectRatio: aspectRatio,
        uiSettings: [
          _buildAndroidUiSettings(context, androidUiSettings),
          _buildIosUiSettings(context, iOSUiSettings),
        ],
      );

      if (croppedFile != null) {
        return XFileWrapper(
          file: XFile(croppedFile.path),
          fileName: wrapperFile.fileName,
        );
      }
      return wrapperFile;
    } catch (e, s) {
      logger.crash(reason: 'Image Cropping Failed', error: e, stackTrace: s);
      return wrapperFile;
    }
  }

  /// Builds the Android UI settings, using custom settings if provided.
  AndroidUiSettings _buildAndroidUiSettings(
    BuildContext context,
    AndroidUiSettings? androidUiSettings,
  ) {
    if (androidUiSettings != null) return androidUiSettings;

    return AndroidUiSettings(
      toolbarTitle: 'Cropper',
      toolbarColor: Colors.deepOrange,
      toolbarWidgetColor: Colors.white,
      cropStyle: cropStyle,
      aspectRatioPresets: aspectRatioPresets,
      initAspectRatio: CropAspectRatioPreset.original,
      lockAspectRatio: aspectRatio != null,
    );
  }

  /// Builds the iOS UI settings, using custom settings if provided.
  IOSUiSettings _buildIosUiSettings(
    BuildContext context,
    IOSUiSettings? iOSUiSettings,
  ) {
    if (iOSUiSettings != null) return iOSUiSettings;

    return IOSUiSettings(
      title: 'Cropper',
      cropStyle: cropStyle,
      aspectRatioPresets: aspectRatioPresets,
      resetAspectRatioEnabled: false,
      aspectRatioPickerButtonHidden: true,
      aspectRatioLockEnabled: aspectRatio != null,
    );
  }
}
