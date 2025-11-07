import 'package:flutter/material.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';

class PickerAction {
  final String title;

  final Widget icon;

  final MediaSource source;

  const PickerAction({
    required this.title,
    required this.icon,
    required this.source,
  });
}
