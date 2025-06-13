import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';

// ignore: one_member_abstracts
abstract class BaseResizer {
  Future<XFileWrapper?> resize(XFileWrapper? wrapperFile);
}
