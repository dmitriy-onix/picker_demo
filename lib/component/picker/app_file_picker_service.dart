import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/config/picker_config.dart';
import 'package:picker_demo/component/picker/pick_file/allowed_file_type.dart';
import 'package:picker_demo/component/picker/pick_file/app_file_picker.dart';
import 'package:picker_demo/component/picker/pick_image/app_image_picker.dart';
import 'package:picker_demo/component/picker/source_selector/default_source_selector_factory.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';

enum PickerUiType { dialog, bottomSheet }

class AppFilePickerService {
  final PickerConfig config;

  AppFilePickerService(this.config);

  /// Picks an image from camera or gallery with source selection UI.
  ///
  /// Shows a source selector allowing the user to choose between camera and gallery.
  /// The selected image will be processed according to [config] settings:
  /// - Cropping (if [PickerConfig.cropper] is configured)
  /// - Resizing (if [PickerConfig.resizer] is configured)
  /// - Compression (if [PickerConfig.compress] is configured)
  ///
  /// [context]: Build context for showing UI
  /// [onShowProgress]: Optional callback invoked when processing starts
  ///
  /// Returns the picked and processed image, or null if cancelled/failed.
  Future<XFileWrapper?> pickImageWithSourceSelection(
    BuildContext context, {
    VoidCallback? onShowProgress,
  }) async {
    if (!context.mounted) return null;

    final factory =
        config.sourceSelectorFactory ??
        DefaultSourceSelectorFactory(uiConfig: config.pickerUIConfig);

    final MediaSource? source = await factory.createSourceSelector(context);

    if (source == null || !context.mounted) return null;
    onShowProgress?.call();

    final imageSource =
        source == MediaSource.camera ? ImageSource.camera : ImageSource.gallery;
    return AppImagePicker(config).pick(context, imageSource);
  }

  /// Picks a document file from device file system.
  ///
  /// Opens the system file picker allowing the user to select a file
  /// matching the allowed types. Image processing options (crop, resize,
  /// compress) do NOT apply to file picking.
  ///
  /// [context]: Build context
  /// [allowedFileTypes]: List of file extensions that can be selected.
  ///   Defaults to PDF and TXT files.
  /// [onShowProgress]: Optional callback invoked when processing starts
  ///
  /// Returns the picked file, or null if cancelled/failed.
  Future<XFileWrapper?> pickFileWithSourceSelection(
    BuildContext context, {
    List<AllowedFileType> allowedFileTypes = const [
      AllowedFileType.pdf,
      AllowedFileType.txt,
    ],
    VoidCallback? onShowProgress,
  }) async {
    if (!context.mounted) return null;
    onShowProgress?.call();
    return AppFilePicker().pickSingleFile(allowedFileTypes: allowedFileTypes);
  }
}
