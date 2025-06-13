import 'dart:math';

import 'package:cross_file/cross_file.dart';

class XFileUtils {
  Future<double> getFileSizeInMb(XFile file) async {
    final sizeInBytes = await file.length();
    final sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }

  Future<double> getFileSizeInKB(XFile file) async {
    final sizeInBytes = await file.length();
    final sizeInKB = sizeInBytes / 1024;
    return sizeInKB;
  }

  Future<String> getFileSizeFormatted(int decimals, XFile file) async {
    final bytes = await file.length();
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
