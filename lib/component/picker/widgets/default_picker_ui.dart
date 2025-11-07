import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picker_demo/component/picker/app_file_picker_service.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/config/picker_ui_config.dart';

class DefaultPickerUI {
  final BuildContext context;
  final PickerUIConfig config;

  DefaultPickerUI({required this.context, required this.config});

  Future<MediaSource?> show() {
    switch (config.uiType) {
      case PickerUiType.bottomSheet:
        return _showCustomBottomSheet();
      case PickerUiType.dialog:
        return _showDialog();
    }
  }

  Future<MediaSource?> _showCustomBottomSheet() {
    return showModalBottomSheet<MediaSource>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    config.sheetTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ..._buildListTiles(ctx),
              ],
            ),
          ),
    );
  }

  List<Widget> _buildListTiles(BuildContext navContext) {
    return config.actions.map((action) {
      return ListTile(
        leading: action.icon,
        title: Text(action.title),
        onTap: () => Navigator.of(navContext).pop(action.source),
      );
    }).toList();
  }

  Future<MediaSource?> _showDialog() {
    return showDialog<MediaSource>(
      context: context,
      builder: (dialogContext) {
        final isIOS = Theme.of(dialogContext).platform == TargetPlatform.iOS;
        return isIOS
            ? _buildCupertinoAlertDialog(dialogContext)
            : _buildMaterialAlertDialog(dialogContext);
      },
    );
  }

  Widget _buildMaterialAlertDialog(BuildContext dialogContext) {
    return AlertDialog(
      title: Text(config.dialogTitle),
      content: SingleChildScrollView(
        child: ListBody(children: _buildListTiles(dialogContext)),
      ),
    );
  }

  Widget _buildCupertinoAlertDialog(BuildContext dialogContext) {
    return CupertinoAlertDialog(
      title: Text(config.dialogTitle),
      actions:
          config.actions.map((action) {
            return CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(action.source),
              child: Text(action.title),
            );
          }).toList(),
    );
  }
}
