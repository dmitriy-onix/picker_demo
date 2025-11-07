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
    this.uiType = PickerUiType.bottomSheet,
    List<MediaSource>? sourcesToShow,
  }) : actions = _createActionsFromSources(
         sourcesToShow ?? MediaSource.values,
       );

  const PickerUIConfig.custom({
    this.sheetTitle = 'Select Source',
    this.dialogTitle = '',
    this.uiType = PickerUiType.bottomSheet,
    required this.actions,
  });

  const PickerUIConfig.defaultConfig({
    this.sheetTitle = 'Select Source',
    this.dialogTitle = 'Select Source',
    this.uiType = PickerUiType.bottomSheet,
    this.actions = const [
      PickerAction(
        title: 'Gallery',
        icon: Icon(Icons.photo_library_outlined),
        source: MediaSource.gallery,
      ),
      PickerAction(
        title: 'Camera',
        icon: Icon(Icons.camera_alt_outlined),
        source: MediaSource.camera,
      ),
      PickerAction(
        title: 'File',
        icon: Icon(Icons.insert_drive_file_outlined),
        source: MediaSource.fileSystem,
      ),
    ],
  });

  static List<PickerAction> _createActionsFromSources(
    List<MediaSource> sources,
  ) {
    final defaultActions = <MediaSource, PickerAction>{
      MediaSource.gallery: const PickerAction(
        title: 'Gallery',
        icon: Icon(Icons.photo_library_outlined),
        source: MediaSource.gallery,
      ),
      MediaSource.camera: const PickerAction(
        title: 'Camera',
        icon: Icon(Icons.camera_alt_outlined),
        source: MediaSource.camera,
      ),
      MediaSource.fileSystem: const PickerAction(
        title: 'File',
        icon: Icon(Icons.insert_drive_file_outlined),
        source: MediaSource.fileSystem,
      ),
    };

    return sources
        .where((source) => defaultActions.containsKey(source))
        .map((source) => defaultActions[source]!)
        .toList();
  }
}
