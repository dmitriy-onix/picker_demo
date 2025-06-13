import 'package:flutter/material.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/source_selector/source_selector_factory.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CustomSourceSelectorFactory implements SourceSelectorFactory {
  final CustomPickerUiType uiType;

  const CustomSourceSelectorFactory(this.uiType);

  @override
  Future<AppFileSource?> createSourceSelector(BuildContext context) {
    return switch(uiType) {
      CustomPickerUiType.adaptiveDialog => _showAdaptiveActionSheet(context),
      CustomPickerUiType.modalBottomSheet => _showModalBottomSheet(context),
    };
  }

  Future<AppFileSource?> _showAdaptiveActionSheet(BuildContext context) {
    return showModalActionSheet<AppFileSource>(
      context: context,
      style: AdaptiveStyle.adaptive,
      actions: _buildSheetActions(context),
    );
  }

  Future<AppFileSource?> _showModalBottomSheet(BuildContext context) {
    return showCupertinoModalBottomSheet<AppFileSource>(
      context: context,
      builder: (context) => Material(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildListTiles(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildListTiles(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.photo_library),
        title: Text('Gallery'),
        onTap: () => Navigator.of(context).pop(AppFileSource.gallery),
      ),
      ListTile(
        leading: const Icon(Icons.camera_alt),
        title: Text('Camera'),
        onTap: () => Navigator.of(context).pop(AppFileSource.camera),
      ),
      ListTile(
        leading: const Icon(Icons.insert_drive_file),
        title: Text('File'),
        onTap: () => Navigator.of(context).pop(AppFileSource.fileSingle),
      ),
    ];
  }

  List<SheetAction<AppFileSource>> _buildSheetActions(BuildContext context) {
    return [
      SheetAction(label: 'Gallery', key: AppFileSource.gallery),
      SheetAction(label: 'Camera', key: AppFileSource.camera),
      SheetAction(label: 'File', key: AppFileSource.fileSingle),
    ];
  }
}

enum CustomPickerUiType { adaptiveDialog, modalBottomSheet }
