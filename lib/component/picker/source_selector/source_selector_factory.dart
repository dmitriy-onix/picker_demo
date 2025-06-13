import 'package:flutter/widgets.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';

abstract class SourceSelectorFactory {
  const SourceSelectorFactory();

  Future<AppFileSource?> createSourceSelector(BuildContext context);
}
