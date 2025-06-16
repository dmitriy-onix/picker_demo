import 'package:flutter/material.dart';
import 'package:picker_demo/component/picker/app_file_picker_service.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/widgets/picker_action.dart';

class PickerUIConfig {
  final String sheetTitle;
  final String dialogTitle;
  final PickerUiType uiType;
  final List<PickerAction> actions;

  PickerUIConfig({
    this.sheetTitle = 'Select Source',
    this.dialogTitle = 'Select Source',
    this.uiType = PickerUiType.customBottomSheet,
    List<AppFileSource>? sourcesToShow,
  }) : actions = _createActionsFromSources(
         sourcesToShow ?? AppFileSource.values,
       );

  const PickerUIConfig.custom({
    this.sheetTitle = 'Select Source',
    this.dialogTitle = '',
    this.uiType = PickerUiType.customBottomSheet,
    required this.actions,
  });

  const PickerUIConfig.defaultConfig({
    this.sheetTitle = 'Select Source',
    this.dialogTitle = 'Select Source',
    this.uiType = PickerUiType.customBottomSheet,
    this.actions = const [
      PickerAction(
        title: 'Gallery',
        icon: Icon(Icons.photo_library_outlined),
        source: AppFileSource.gallery,
      ),
      PickerAction(
        title: 'Camera',
        icon: Icon(Icons.camera_alt_outlined),
        source: AppFileSource.camera,
      ),
      PickerAction(
        title: 'File',
        icon: Icon(Icons.insert_drive_file_outlined),
        source: AppFileSource.fileSingle,
      ),
    ],
  });

  static List<PickerAction> _createActionsFromSources(
    List<AppFileSource> sources,
  ) {
    final defaultActions = <AppFileSource, PickerAction>{
      AppFileSource.gallery: const PickerAction(
        title: 'Gallery',
        icon: Icon(Icons.photo_library_outlined),
        source: AppFileSource.gallery,
      ),
      AppFileSource.camera: const PickerAction(
        title: 'Camera',
        icon: Icon(Icons.camera_alt_outlined),
        source: AppFileSource.camera,
      ),
      AppFileSource.fileSingle: const PickerAction(
        title: 'File',
        icon: Icon(Icons.insert_drive_file_outlined),
        source: AppFileSource.fileSingle,
      ),
    };

    return sources
        .where((source) => defaultActions.containsKey(source))
        .map((source) => defaultActions[source]!)
        .toList();
  }
}
