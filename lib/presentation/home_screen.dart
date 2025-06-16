import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:picker_demo/component/picker/app_file_picker_service.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/config/picker_config.dart';
import 'package:picker_demo/component/picker/config/picker_ui_config.dart';
import 'package:picker_demo/component/picker/pick_image/compressors/image_compressor.dart';
import 'package:picker_demo/component/picker/pick_image/croppers/free_cropper.dart';
import 'package:picker_demo/component/picker/pick_image/resizers/image_resizer.dart';
import 'package:picker_demo/component/picker/widgets/picker_action.dart';
import 'package:picker_demo/component/picker/x_file/x_file_wrapper.dart';
import 'package:picker_demo/logger/app_logger_impl.dart';
import 'package:picker_demo/presentation/custom_source_selector_factory.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFileWrapper? _imageFile;

  @override
  Widget build(BuildContext context) {
    final imageFile = _imageFile;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(child: Text('Home Screen')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _selectDocumentCustom(context, PickerUiType.customBottomSheet);
              },
              child: const Text('Select document customBottomSheet'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _selectDocument(context, PickerUiType.dialog, [
                  AppFileSource.gallery,
                  AppFileSource.camera,
                ]);
              },
              child: const Text('Select document adaptiveDialog'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _selectDocumentCustomSourceUi(
                  context,
                  CustomPickerUiType.adaptiveDialog,
                );
              },
              child: const Text('Select document custom adaptiveDialog'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _selectDocumentCustomSourceUi(
                  context,
                  CustomPickerUiType.modalBottomSheet,
                );
              },
              child: const Text('Select document custom modalBottomSheet'),
            ),
            SizedBox(height: 30),
            if (imageFile != null)
              Image.file(
                File(imageFile.file.path),
                fit: BoxFit.contain,
                width: 300,
                height: 300,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Could not load image.');
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDocumentCustom(
    BuildContext context,
    PickerUiType pickerType,
  ) async {
    final config = PickerConfig(
      cropper: FreeCropper(cropStyle: CropStyle.rectangle),
      compress: ImageCompressor(fileLimitMb: 1),
      resizer: ImageResizer(),
      pickerUIConfig: PickerUIConfig.custom(
        sheetTitle: 'Select Source custom',
        uiType: PickerUiType.customBottomSheet,
        actions: [
          PickerAction(
            title: 'Custom Gallery',
            icon: const Icon(Icons.photo_library),
            source: AppFileSource.gallery,
          ),
          PickerAction(
            title: 'Custom Camera',
            icon: const Icon(Icons.camera_alt),
            source: AppFileSource.camera,
          ),
        ],
      ),
    );

    final pickerService = AppFilePickerService(config);

    final XFileWrapper? result = await pickerService
        .pickFileWithSourceSelection(
          context,
          onShowProgress: () {
            _showProgressDialog(context);
          },
        );

    if (!context.mounted) return;
    _hideProgressDialog(context);

    if (result != null && context.mounted) {
      logger.i('result: $result');
      setState(() {
        _imageFile = result;
      });
    }
  }

  Future<void> _selectDocument(
    BuildContext context,
    PickerUiType pickerType, [
    List<AppFileSource>? sourcesToShow = const [
      AppFileSource.gallery,
      AppFileSource.camera,
      AppFileSource.fileSingle,
    ],
  ]) async {
    final config = PickerConfig(
      cropper: FreeCropper(cropStyle: CropStyle.rectangle),
      compress: ImageCompressor(fileLimitMb: 1),
      resizer: ImageResizer(),
      pickerUIConfig: PickerUIConfig(
        uiType: PickerUiType.dialog,
        sourcesToShow: sourcesToShow,
        sheetTitle: 'Select Source',
        dialogTitle: 'Select Source',
      ),
    );

    final pickerService = AppFilePickerService(config);

    final XFileWrapper? result = await pickerService
        .pickFileWithSourceSelection(
          context,
          onShowProgress: () {
            _showProgressDialog(context);
          },
        );

    if (!context.mounted) return;
    _hideProgressDialog(context);

    if (result != null && context.mounted) {
      logger.i('result: $result');
      setState(() {
        _imageFile = result;
      });
    }
  }

  Future<void> _selectDocumentCustomSourceUi(
    BuildContext context,
    CustomPickerUiType pickerType,
  ) async {
    final config = PickerConfig(
      cropper: FreeCropper(cropStyle: CropStyle.rectangle),
      compress: ImageCompressor(fileLimitMb: 2),
      sourceSelectorFactory: CustomSourceSelectorFactory(pickerType),
    );

    final pickerService = AppFilePickerService(config);

    final XFileWrapper? result = await pickerService
        .pickFileWithSourceSelection(
          context,
          onShowProgress: () {
            _showProgressDialog(context);
          },
        );

    if (!context.mounted) return;
    _hideProgressDialog(context);

    if (result != null && context.mounted) {
      logger.i('result: $result');
      setState(() {
        _imageFile = result;
      });
    }
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void _hideProgressDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
