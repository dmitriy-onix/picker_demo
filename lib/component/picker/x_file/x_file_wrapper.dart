import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';

class XFileWrapper extends Equatable {
  final XFile file;
  final String fileName;

  const XFileWrapper({required this.file, required this.fileName});

  @override
  List<Object?> get props => [file, fileName];
}
