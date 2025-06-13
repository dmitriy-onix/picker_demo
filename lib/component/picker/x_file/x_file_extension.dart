import 'package:cross_file/cross_file.dart';
import 'package:picker_demo/component/picker/x_file/x_file_utils.dart';

extension XfileExt on XFile {
  Future<String> getFileSizeFormatted(int decimals) async {
    return XFileUtils().getFileSizeFormatted(decimals, this);
  }

  Future<double> get sizeInMb async {
    return XFileUtils().getFileSizeInMb(this);
  }

  Future<double> get sizeInKB async {
    return XFileUtils().getFileSizeInKB(this);
  }
}
