import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/config/picker_config.dart';
import 'package:picker_demo/component/picker/pick_file/allowed_file_type.dart';
import 'package:picker_demo/component/picker/pick_file/app_file_picker.dart';
import 'package:picker_demo/component/picker/pick_image/app_image_picker.dart';
import 'package:picker_demo/component/picker/source_selector/default_source_selector_factory.dart';
import 'package:picker_demo/component/picker/source_selector/source_selector_factory.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';

enum PickerUiType { dialog, customBottomSheet }

class AppFilePickerService {
  final PickerConfig config;

  AppFilePickerService(this.config);

  Future<XFileWrapper?> pickFileWithSourceSelection(
    BuildContext context, {
    List<AllowedFileType> allowedFileExtensions = const [
      AllowedFileType.pdf,
      AllowedFileType.txt,
    ],
    VoidCallback? onShowProgress,
  }) async {
    AppFileSource? source;
    if (!context.mounted) return null;

    final sourceSelector = config.sourceSelectorFactory;
    if (sourceSelector != null) {
      source = await _createSourceSelectorWithFactory(
        context,
        factory: sourceSelector,
      );
    } else {
      source = await _showSourceSelector(context);
    }

    if (source == null || !context.mounted) return null;
    onShowProgress?.call();
    return _pick(context, source, allowedFileExtensions);
  }

  Future<AppFileSource?> _showSourceSelector(BuildContext context) async {
    final factory = DefaultSourceSelectorFactory(
      config: config,
    );
    return _createSourceSelectorWithFactory(context, factory: factory);
  }

  Future<AppFileSource?> _createSourceSelectorWithFactory(
    BuildContext context, {
    required SourceSelectorFactory factory,
  }) {
    return factory.createSourceSelector(context);
  }

  Future<XFileWrapper?> _pick(
    BuildContext context,
    AppFileSource source,
    List<AllowedFileType> allowedExtensions,
  ) {
    switch (source) {
      case AppFileSource.gallery:
      case AppFileSource.camera:
        final imagePicker = AppImagePicker(config);
        final imageSource =
            source == AppFileSource.camera
                ? ImageSource.camera
                : ImageSource.gallery;
        return imagePicker.pick(context, imageSource);
      case AppFileSource.fileSingle:
        return AppFilePicker().pickSingleFile(
          allowedFileTypes: allowedExtensions,
        );
    }
  }
}
