import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/source_selector/source_selector_factory.dart';

class CustomSourceSelectorFactory implements SourceSelectorFactory {
  final CustomPickerUiType uiType;

  final List<MediaSource> sourcesToShow;

  const CustomSourceSelectorFactory(
    this.uiType, [
    this.sourcesToShow = const [MediaSource.gallery, MediaSource.camera],
  ]);

  @override
  Future<MediaSource?> createSourceSelector(BuildContext context) {
    return switch (uiType) {
      CustomPickerUiType.adaptiveActionSheet => _showAdaptiveActionSheet(
        context,
      ),
      CustomPickerUiType.iosActionSheet => _showAdaptiveActionSheet(
        context,
        AdaptiveStyle.iOS,
      ),
      CustomPickerUiType.materialActionSheet => _showAdaptiveActionSheet(
        context,
        AdaptiveStyle.material,
      ),
      CustomPickerUiType.modalBottomSheet => _showModalBottomSheet(context),
    };
  }

  Future<MediaSource?> _showAdaptiveActionSheet(
    BuildContext context, [
    AdaptiveStyle style = AdaptiveStyle.adaptive,
  ]) {
    return showModalActionSheet<MediaSource>(
      context: context,
      style: style,
      actions: _buildSheetActions(context),
    );
  }

  Future<MediaSource?> _showModalBottomSheet(BuildContext context) {
    return showMaterialModalBottomSheet<MediaSource>(
      context: context,
      builder:
          (context) => Material(
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
    final sources = sourcesToShow.isEmpty
        ? const [MediaSource.gallery, MediaSource.camera]
        : sourcesToShow;

    return sources.map((source) {
      final config = _getSourceConfig(source);
      return ListTile(
        leading: Icon(config.icon),
        title: Text(config.label),
        onTap: () => Navigator.of(context).pop(source),
      );
    }).toList();
  }

  List<SheetAction<MediaSource>> _buildSheetActions(BuildContext context) {
    final sources = sourcesToShow.isEmpty
        ? const [MediaSource.gallery, MediaSource.camera]
        : sourcesToShow;

    return sources.map((source) {
      final config = _getSourceConfig(source);
      return SheetAction(label: config.label, key: source);
    }).toList();
  }

  _SourceConfig _getSourceConfig(MediaSource source) {
    return switch (source) {
      MediaSource.gallery => const _SourceConfig(
          label: 'Gallery',
          icon: Icons.photo_library,
        ),
      MediaSource.camera => const _SourceConfig(
          label: 'Camera',
          icon: Icons.camera_alt,
        ),
      MediaSource.fileSystem => const _SourceConfig(
          label: 'File',
          icon: Icons.insert_drive_file,
        ),
    };
  }
}

class _SourceConfig {
  final String label;
  final IconData icon;

  const _SourceConfig({
    required this.label,
    required this.icon,
  });
}

enum CustomPickerUiType {
  iosActionSheet,
  materialActionSheet,
  adaptiveActionSheet,
  modalBottomSheet,
}
