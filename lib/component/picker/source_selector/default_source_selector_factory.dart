import 'package:flutter/widgets.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/config/picker_ui_config.dart';
import 'package:picker_demo/component/picker/source_selector/source_selector_factory.dart';
import 'package:picker_demo/component/picker/widgets/default_picker_ui.dart';

class DefaultSourceSelectorFactory implements SourceSelectorFactory {
  final PickerUIConfig? uiConfig;

  DefaultSourceSelectorFactory({this.uiConfig});

  @override
  Future<MediaSource?> createSourceSelector(BuildContext context) {
    final pickerUI = DefaultPickerUI(
      context: context,
      config: uiConfig ?? const PickerUIConfig.defaultConfig(),
    );
    return pickerUI.show();
  }
}
