import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picker_demo/component/picker/config/picker_config.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';
import 'package:picker_demo/logger/app_logger_impl.dart';

class AppImagePicker {
  final PickerConfig config;

  AppImagePicker(this.config);

  Future<XFileWrapper?> pick(
    BuildContext context,
    ImageSource imageSource,
  ) async {
    try {
      final XFile? pickedFile = await _pickImage(imageSource);
      if (pickedFile == null) return null;

      XFileWrapper? fileWrapper = XFileWrapper(
        file: pickedFile,
        fileName: pickedFile.name,
      );

      if (context.mounted) {
        fileWrapper = await _tryCropImage(context, fileWrapper);
      }
      fileWrapper = await _tryResizeImage(fileWrapper);
      fileWrapper = await _tryCompressImage(fileWrapper);

      return fileWrapper;
    } catch (e, s) {
      logger.crash(error: e, stackTrace: s);
      return null;
    }
  }

  Future<XFile?> _pickImage(ImageSource imageSource) async {
    final ReceivePort receivePort = ReceivePort();
    final RootIsolateToken? isolateToken = RootIsolateToken.instance;
    if (isolateToken == null) {
      return null;
    }
    await Isolate.spawn(_isolatePickImage, [
      isolateToken,
      receivePort.sendPort,
      imageSource,
    ]);
    final String? path = await receivePort.first;
    if (path == null) {
      return null;
    }
    return XFile(path);
  }

  Future<XFileWrapper?> _tryCropImage(
    BuildContext context,
    XFileWrapper? file,
  ) async {
    final imageCropper = config.cropper;
    if (imageCropper != null) {
      return await imageCropper.crop(context, file);
    }
    return file;
  }

  Future<XFileWrapper?> _tryResizeImage(XFileWrapper? file) async {
    final imageResizer = config.resizer;
    if (imageResizer != null) {
      return await imageResizer.resize(file);
    }
    return file;
  }

  Future<XFileWrapper?> _tryCompressImage(XFileWrapper? file) async {
    final imageCompress = config.compress;
    if (imageCompress != null) {
      return await imageCompress.compress(file);
    }
    return file;
  }
}

Future<void> _isolatePickImage(List<dynamic> args) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(args[0]);
  final SendPort sendPort = args[1];
  final ImageSource imageSource = args[2];
  final ImagePicker imagePicker = ImagePicker();
  final XFile? file = await imagePicker.pickImage(source: imageSource);
  sendPort.send(file?.path);
}
