import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:picker_demo/component/picker/pick_image/compressors/base_compress.dart';
import 'package:picker_demo/component/picker/x_file/x_file_extension.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';
import 'package:picker_demo/logger/app_logger_impl.dart';

class CompressionRequest {
  final RootIsolateToken token;
  final SendPort sendPort;
  final String filePath;
  final String targetPath;
  final int quality;

  CompressionRequest(
    this.token,
    this.sendPort,
    this.filePath,
    this.targetPath,
    this.quality,
  );
}

class ImageCompressor implements BaseCompress {
  /// The target file size limit in megabytes.
  final double fileLimitMb;

  /// The initial quality for the first compression attempt (1-100).
  final int initialQuality;

  /// The minimum quality to reach before giving up (1-100). Prevents over-compression.
  final int minQuality;

  /// The number of steps to decrease quality in each attempt.
  final int qualityStep;

  /// The maximum number of compression attempts to prevent infinite loops.
  final int maxAttempts;

  static Future<void> _compressImage(CompressionRequest request) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(request.token);

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      request.filePath,
      request.targetPath,
      quality: request.quality,
    );

    request.sendPort.send(compressedImage?.path);
  }

  Future<XFile?> compressImageInIsolate(
    String filePath,
    String targetPath,
    int quality,
  ) async {
    final RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    final compressionRequest = CompressionRequest(
      rootIsolateToken,
      sendPort,
      filePath,
      targetPath,
      quality,
    );

    await Isolate.spawn(_compressImage, compressionRequest);

    final compressedImagePath = await receivePort.first as String?;
    return compressedImagePath != null ? XFile(compressedImagePath) : null;
  }

  ImageCompressor({
    this.fileLimitMb = 10.0,
    this.initialQuality = 100,
    this.minQuality = 60,
    this.qualityStep = 5,
    this.maxAttempts = 10,
  });

  @override
  Future<XFileWrapper?> compress(XFileWrapper? wrapperFile) async {
    if (wrapperFile == null) return null;

    final file = wrapperFile.file;

    final fileLimitInKb = fileLimitMb * 1024;
    final sizeInKB = await file.sizeInKB;

    logger.i('sizeInKB: $sizeInKB, fileLimitInKb: $fileLimitInKb');

    if (sizeInKB <= fileLimitInKb) {
      await _tryPrintToConsoleFileSize(
        resultFile: wrapperFile.file,
        message: 'File is already within size limit. Size:',
      );
      return wrapperFile;
    }

    try {
      await _tryPrintToConsoleFileSize(
        resultFile: file,
        message: 'Compressing... Original file size:',
      );

      final tempDir = await getTemporaryDirectory();
      XFile compressedFile = file;
      int currentQuality = initialQuality;
      int attempts = 0;
      double currentSizeInKB = await compressedFile.sizeInKB;

      while (attempts < maxAttempts && currentSizeInKB > fileLimitInKb) {
        if (currentQuality < minQuality) {
          if (kDebugMode) {
            logger.w(
              'Reached minimum quality of $minQuality. Stopping compression.',
            );
          }
          break;
        }

        final targetPath = p.join(
          tempDir.path,
          'c_${DateTime.now().millisecondsSinceEpoch}_${wrapperFile.fileName}',
        );

        final result = await compressImageInIsolate(
          compressedFile.path,
          targetPath,
          currentQuality,
        );

        if (result == null) {
          if (kDebugMode) {
            logger.w(
              'Compression failed at quality $currentQuality. Returning previous version.',
            );
          }
          break;
        }

        compressedFile = result;
        currentQuality -= qualityStep;
        attempts++;
        currentSizeInKB = await compressedFile.sizeInKB;

        await _tryPrintToConsoleFileSize(
          resultFile: compressedFile,
          message: 'Attempt $attempts: Quality $currentQuality, Size:',
        );
      }

      await _tryPrintToConsoleFileSize(
        resultFile: compressedFile,
        message: 'Compression finished. Final size:',
      );

      return XFileWrapper(file: compressedFile, fileName: wrapperFile.fileName);
    } catch (e, s) {
      logger.crash(reason: 'Image Compression Failed', error: e, stackTrace: s);
      return wrapperFile;
    }
  }

  Future<void> _tryPrintToConsoleFileSize({
    required XFile? resultFile,
    String message = '',
  }) async {
    if (kDebugMode) {
      final size = await resultFile?.getFileSizeFormatted(2) ?? '';
      logger.i('$message $size');
    }
  }
}
