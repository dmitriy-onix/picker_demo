import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';
import 'package:picker_demo/logger/app_logger_impl.dart';

import 'allowed_file_type.dart';

/// A service class for picking files from the device storage.
///
/// Wraps the `file_picker` package to provide a simplified and robust API
/// consistent with the application's architecture.
class AppFilePicker {
  /// Picks a single file from the device.
  ///
  /// [allowedFileTypes]: A list of file types that the user is allowed to pick.
  /// Returns an [XFileWrapper] if a file is selected, otherwise null.
  Future<XFileWrapper?> pickSingleFile({
    required List<AllowedFileType> allowedFileTypes,
  }) async {
    try {
      final List<String> extensions =
          allowedFileTypes.map((e) => e.extension).toList();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final path = pickedFile.path;
        final name = pickedFile.name;

        if (path != null) {
          return XFileWrapper(file: XFile(path, name: name), fileName: name);
        }
      }
      return null;
    } catch (e, s) {
      logger.crash(
        reason: 'Single File Picking Failed',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  /// Picks multiple files from the device.
  ///
  /// [allowedFileTypes]: A list of file types that the user is allowed to pick.
  /// Returns a list of [XFileWrapper]s. The list is empty if no files are
  /// selected or if an error occurs.
  Future<List<XFileWrapper>> pickMultipleFiles({
    required List<AllowedFileType> allowedFileTypes,
  }) async {
    try {
      final List<String> extensions =
          allowedFileTypes.map((e) => e.extension).toList();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final List<XFileWrapper> wrappers = [];
        for (final pickedFile in result.files) {
          final path = pickedFile.path;
          final name = pickedFile.name;
          if (path != null) {
            wrappers.add(
              XFileWrapper(file: XFile(path, name: name), fileName: name),
            );
          }
        }
        return wrappers;
      }
      return [];
    } catch (e, s) {
      logger.crash(
        reason: 'Multiple File Picking Failed',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }
}
