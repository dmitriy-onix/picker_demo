
enum AllowedFileType {
  // Document Types
  pdf('pdf'),
  txt('txt'),
  docx('docx'),
  xlsx('xlsx'),

  // Image Types
  svg('svg'),
  gif('gif'),

  // Add other file types as needed
  mp4('mp4');

  /// The file extension string (e.g., 'pdf', 'jpg').
  final String extension;

  const AllowedFileType(this.extension);
}
