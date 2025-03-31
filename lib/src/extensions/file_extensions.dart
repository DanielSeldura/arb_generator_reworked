import 'dart:io';
import 'package:path/path.dart' as path;

/// Extensions on [File]
extension FileExtensions on File {
  /// Whether the file has a valid extension
  bool get hasValidExtension => extensionType == '.xlsx';

  /// The file extension
  String get extensionType => path.extension(this.path).toLowerCase();
}
