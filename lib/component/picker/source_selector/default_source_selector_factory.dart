import 'package:flutter/widgets.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/config/picker_config.dart';
import 'package:picker_demo/component/picker/config/picker_ui_config.dart';
import 'package:picker_demo/component/picker/source_selector/source_selector_factory.dart';
import 'package:picker_demo/component/picker/widgets/default_picker_ui.dart';

class DefaultSourceSelectorFactory implements SourceSelectorFactory {
  final PickerConfig? config;

  DefaultSourceSelectorFactory({this.config});

  @override
  Future<AppFileSource?> createSourceSelector(BuildContext context) {
    final pickerUI = DefaultPickerUI(
      context: context,
      config: config?.pickerUIConfig ?? const PickerUIConfig.defaultConfig(),
    );
    return pickerUI.show();
  }
}
