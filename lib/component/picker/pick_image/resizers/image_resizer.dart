import 'dart:io';
import 'dart:math';
import 'package:picker_demo/logger/app_logger_impl.dart';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:picker_demo/component/picker/pick_image/resizers/base_resizer.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';


/// A class for resizing images while maintaining aspect ratio.
///
/// It runs the resizing process in a separate isolate to prevent UI jank.
class ImageResizer implements BaseResizer {
  /// The maximum number of pixels (width * height) for the output image.
  final int maxPixelCount;

  /// The quality of the output JPEG image (1-100).
  final int encodingQuality;

  ImageResizer({
    this.maxPixelCount = 1920 * 1080,
    this.encodingQuality = 90,
  });

  @override
  Future<XFileWrapper?> resize(XFileWrapper? wrapperFile) async {
    if (wrapperFile == null) return null;

    try {
      final args = _ResizeArgs(wrapperFile.file, maxPixelCount);

      // Perform the heavy lifting in a background isolate
      final img.Image? resizedImage = await compute(_resizeImageIsolate, args);

      if (resizedImage == null) {
        // This can happen if the original file is not a valid image
        // or is already smaller than the target size.
        return wrapperFile;
      }

      if (kDebugMode) {
        logger.i('Image resized to: ${resizedImage.width}x${resizedImage.height}');
      }

      // Encode the resized image and save it to a temporary file
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(tempDir.path, 'r_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final resizedFile = await File(targetPath).writeAsBytes(
        img.encodeJpg(resizedImage, quality: encodingQuality),
      );

      return XFileWrapper(
        file: XFile(resizedFile.path),
        fileName: wrapperFile.fileName,
      );
    } catch (e, s) {
      logger.crash(reason: 'Image Resizing Failed', error: e, stackTrace: s);
      return wrapperFile;
    }
  }
}

class _ResizeArgs {
  final XFile file;
  final int maxPixelCount;

  _ResizeArgs(this.file, this.maxPixelCount);
}

/// This function runs in a separate isolate.
/// It must be a top-level function or a static method.
Future<img.Image?> _resizeImageIsolate(_ResizeArgs args) async {
  final bytes = await args.file.readAsBytes();
  final originalImage = img.decodeImage(bytes);

  if (originalImage == null) return null;

  // If the image is already small enough, no need to resize.
  if (originalImage.width * originalImage.height <= args.maxPixelCount) {
    return null;
  }

  // Calculate the new dimensions while preserving aspect ratio
  final double aspectRatio = originalImage.width / originalImage.height;
  final double newWidth = (originalImage.width > originalImage.height)
      ? sqrt(args.maxPixelCount * aspectRatio)
      : sqrt(args.maxPixelCount / aspectRatio);

  final int targetWidth = newWidth.round();

  return img.copyResize(originalImage, width: targetWidth);
}