import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picker_demo/component/picker/app_file_picker_service.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';

class DefaultPickerUI {
  //TODO: implement configuration for picker UI
  static final DefaultPickerUI _instance = DefaultPickerUI._();

  static DefaultPickerUI get I => _instance;

  DefaultPickerUI._();

  Future<AppFileSource?> fromPickerUiType({
    required BuildContext context,
    required PickerUiType uiType,
  }) {
    return _showSourceSelector(context, uiType);
  }

  Future<AppFileSource?> _showSourceSelector(
    BuildContext context,
    PickerUiType uiType,
  ) {
    switch (uiType) {
      case PickerUiType.customBottomSheet:
        return _showCustomBottomSheet(context);
      case PickerUiType.dialog:
        return _showDialog(context);
    }
  }

  Future<AppFileSource?> _showCustomBottomSheet(BuildContext context) {
    return showModalBottomSheet<AppFileSource>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Select option',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ..._buildListTiles(context),
              ],
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

  Future<AppFileSource?> _showDialog(BuildContext context) {
    return showDialog<AppFileSource>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Theme.of(dialogContext).platform == TargetPlatform.iOS
            ? _buildCupertinoAlertDialog(dialogContext)
            : _buildMaterialAlertDialog(dialogContext);
      },
    );
  }

  Widget _buildMaterialAlertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Select option'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop(AppFileSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop(AppFileSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('File'),
              onTap: () {
                Navigator.of(context).pop(AppFileSource.fileSingle);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoAlertDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Select option'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop(AppFileSource.gallery);
          },
          child: const Text('Gallery'),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop(AppFileSource.camera);
          },
          child: const Text('Camera'),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop(AppFileSource.fileSingle);
          },
          child: const Text('File'),
        ),
      ],
    );
  }
}
