import 'package:flutter/widgets.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';

// ignore: one_member_abstracts
abstract class BaseCropper {
  Future<XFileWrapper?> crop(BuildContext context, XFileWrapper? wrapperFile);
}
