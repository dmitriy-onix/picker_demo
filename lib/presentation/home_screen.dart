import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:picker_demo/component/picker/app_file_picker_service.dart';
import 'package:picker_demo/component/picker/app_file_source.dart';
import 'package:picker_demo/component/picker/config/picker_config.dart';
import 'package:picker_demo/component/picker/config/picker_ui_config.dart';
import 'package:picker_demo/component/picker/pick_file/allowed_file_type.dart';
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
  XFileWrapper? _selectedFile;

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
                _selectImageCustom(context, PickerUiType.bottomSheet);
              },
              child: const Text('Select image bottomSheet'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _selectImage(context, PickerUiType.dialog);
              },
              child: const Text('Select image dialog'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _selectImageCustomSourceUi(
                  context,
                  CustomPickerUiType.iosActionSheet,
                );
              },
              child: const Text('Select image custom iosActionSheet'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _selectImageCustomSourceUi(
                  context,
                  CustomPickerUiType.materialActionSheet,
                  [MediaSource.camera],
                );
              },
              child: const Text('Select image custom materialActionSheet'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _selectImageCustomSourceUi(
                  context,
                  CustomPickerUiType.modalBottomSheet,
                  [MediaSource.gallery],
                );
              },
              child: const Text('Select image custom modalBottomSheet'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _selectFile(context);
              },
              child: const Text('Select document file'),
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
            if (_selectedFile != null) ...[
              SizedBox(height: 20),
              Text('Selected file: ${_selectedFile!.fileName}'),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectImageCustom(
    BuildContext context,
    PickerUiType pickerType,
  ) async {
    final config = PickerConfig(
      cropper: FreeCropper(cropStyle: CropStyle.rectangle),
      compress: ImageCompressor(fileLimitMb: 1),
      resizer: ImageResizer(),
      pickerUIConfig: PickerUIConfig.custom(
        sheetTitle: 'Select Source custom labels and icons',
        uiType: PickerUiType.bottomSheet,
        actions: [
          PickerAction(
            title: 'Custom Gallery',
            icon: const Icon(Icons.photo_library),
            source: MediaSource.gallery,
          ),
          PickerAction(
            title: 'Custom Camera',
            icon: const Icon(Icons.camera_alt),
            source: MediaSource.camera,
          ),
        ],
      ),
    );

    final pickerService = AppFilePickerService(config);

    final XFileWrapper? result = await pickerService
        .pickImageWithSourceSelection(
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

  Future<void> _selectImage(
    BuildContext context,
    PickerUiType pickerType, [
    List<MediaSource>? sourcesToShow = const [
      MediaSource.gallery,
      MediaSource.camera,
    ],
  ]) async {
    final config = PickerConfig(
      cropper: FreeCropper(cropStyle: CropStyle.rectangle),
      compress: ImageCompressor(fileLimitMb: 1),
      resizer: ImageResizer(),
      pickerUIConfig: PickerUIConfig(
        uiType: pickerType,
        sheetTitle: 'Select Source',
        dialogTitle: 'Select Source',
        sourcesToShow: sourcesToShow,
      ),
    );

    final pickerService = AppFilePickerService(config);

    final XFileWrapper? result = await pickerService
        .pickImageWithSourceSelection(
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

  Future<void> _selectImageCustomSourceUi(
    BuildContext context,
    CustomPickerUiType pickerType, [
    List<MediaSource> sourcesToShow = const [
      MediaSource.gallery,
      MediaSource.camera,
    ],
  ]) async {
    final config = PickerConfig(
      cropper: FreeCropper(cropStyle: CropStyle.rectangle),
      compress: ImageCompressor(fileLimitMb: 2),
      sourceSelectorFactory: CustomSourceSelectorFactory(
        pickerType,
        sourcesToShow,
      ),
    );

    final pickerService = AppFilePickerService(config);

    final XFileWrapper? result = await pickerService
        .pickImageWithSourceSelection(
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

  Future<void> _selectFile(BuildContext context) async {
    final config = PickerConfig(
      pickerUIConfig: PickerUIConfig(dialogTitle: 'Select Document'),
    );

    final pickerService = AppFilePickerService(config);

    final XFileWrapper? result = await pickerService
        .pickFileWithSourceSelection(
          context,
          allowedFileTypes: [AllowedFileType.pdf, AllowedFileType.txt],
          onShowProgress: () {
            _showProgressDialog(context);
          },
        );

    if (!context.mounted) return;
    _hideProgressDialog(context);

    if (result != null && context.mounted) {
      logger.i('Selected file: ${result.fileName}');
      setState(() {
        _selectedFile = result;
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
