import 'package:image_picker/image_picker.dart';
import 'package:picker_demo/component/picker/config/picker_ui_config.dart';
import 'package:picker_demo/component/picker/pick_image/compressors/base_compress.dart';
import 'package:picker_demo/component/picker/pick_image/croppers/base_cropper.dart';
import 'package:picker_demo/component/picker/pick_image/resizers/base_resizer.dart';
import 'package:picker_demo/component/picker/source_selector/source_selector_factory.dart';

class PickerConfig {
  final BaseCropper? cropper;
  final BaseResizer? resizer;
  final BaseCompress? compress;
  final CameraDevice preferredCameraDevice;

  final SourceSelectorFactory? sourceSelectorFactory;

  final PickerUIConfig? pickerUIConfig;

  const PickerConfig({
    this.cropper,
    this.resizer,
    this.compress,
    this.sourceSelectorFactory,
    this.pickerUIConfig,
    this.preferredCameraDevice = CameraDevice.rear,
  });
}
