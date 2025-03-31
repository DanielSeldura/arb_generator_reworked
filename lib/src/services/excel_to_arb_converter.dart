import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';

/// A service which converts Excel files to ARB format
/// This converter handles Excel files (.xlsx) directly, preserving multi-line text
class ExcelToARBConverter {
  /// Converts an Excel file into ARB files
  /// [excelPath] - Path to the Excel file
  /// [outputDir] - Directory where ARB files should be saved
  /// [sheet] - Name of the sheet to process (optional, uses first sheet if not specified)
  static void convert({
    required String excelPath,
    required String outputDir,
    String? sheet,
  }) {
    // Read Excel file
    final file = File(excelPath);
    if (!file.existsSync()) {
      throw FileSystemException('Excel file does not exist');
    }

    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    // Get the target sheet
    final targetSheet = sheet != null
        ? excel.sheets[sheet]
        : excel.sheets[excel.sheets.keys.first];

    if (targetSheet == null) {
      throw Exception('Sheet not found');
    }

    // Clean up output directory
    final dir = Directory(outputDir);
    if (dir.existsSync()) {
      dir.listSync().forEach((entity) {
        if (entity is File && entity.path.endsWith('.arb')) {
          entity.deleteSync();
        }
      });
    } else {
      dir.createSync(recursive: true);
    }

    // Get headers (first row)
    final headers = <String>[];
    for (var cell in targetSheet.row(0)) {
      headers.add(cell?.value?.toString().trim() ?? '');
    }

    if (headers.length < 4) {
      throw Exception(
          'Excel must have at least 4 columns: key, description, and 2 languages');
    }

    // Process each language (starting from index 2, after key and description)
    for (var i = 2; i < headers.length; i++) {
      final locale = headers[i].replaceAll(RegExp(r'[^a-zA-Z_-]'), '');
      final arbData = <String, dynamic>{};
      final sortedKeys = <String>[];

      // First pass: collect all keys and their data
      for (var rowIndex = 1; rowIndex < targetSheet.maxRows; rowIndex++) {
        final row = targetSheet.row(rowIndex);
        if (row.isEmpty || row[0]?.value == null) continue;

        final key = row[0]?.value.toString().trim() ?? '';
        final description = row[1]?.value?.toString().trim() ?? '';
        final value = row[i]?.value?.toString().trim() ?? '';

        // Skip empty keys
        if (key.isEmpty) continue;

        sortedKeys.add(key);
        arbData[key] = value;
        if (description.isNotEmpty) {
          arbData['@$key'] = {
            'description': description,
          };
        }
      }

      // Sort keys alphabetically
      sortedKeys.sort();

      // Create final ARB data with sorted keys
      final sortedArbData = <String, dynamic>{
        '@@locale': locale,
      };

      // Add keys in sorted order
      for (final key in sortedKeys) {
        sortedArbData[key] = arbData[key];
        if (arbData.containsKey('@$key')) {
          sortedArbData['@$key'] = arbData['@$key'];
        }
      }

      // Write ARB file
      final arbFile = File('$outputDir/app_$locale.arb');
      final encoder = JsonEncoder.withIndent('  ');
      arbFile.writeAsStringSync(encoder.convert(sortedArbData));
      print('Generated ${arbFile.path}');
    }

    print('Successfully converted Excel to ARB files');
  }
}
