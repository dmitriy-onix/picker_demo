import 'package:flutter/widgets.dart';
import 'package:picker_demo/component/picker/app_file_picker_service.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/source_selector/source_selector_factory.dart';
import 'package:picker_demo/component/picker/widgets/default_picker_ui.dart';

class DefaultSourceSelectorFactory implements SourceSelectorFactory {
  final PickerUiType uiType;

  const DefaultSourceSelectorFactory(this.uiType);

  @override
  Future<AppFileSource?> createSourceSelector(BuildContext context) {
    return DefaultPickerUI.I.fromPickerUiType(context: context, uiType: uiType);
  }
}
