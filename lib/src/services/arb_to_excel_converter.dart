import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';

/// A service which converts ARB files to Excel format
/// This converter generates Excel files that preserve multi-line text and formatting
class ARBToExcelConverter {
  /// Converts two ARB files into an Excel file
  /// [arbFile1Path] - Path to the first ARB file (base language)
  /// [arbFile2Path] - Path to the second ARB file
  /// [outputPath] - Path where the Excel file should be saved
  static void convert({
    required String arbFile1Path,
    required String arbFile2Path,
    required String outputPath,
  }) {
    // Read and parse ARB files
    final file1 = File(arbFile1Path);
    final file2 = File(arbFile2Path);

    if (!file1.existsSync() || !file2.existsSync()) {
      throw FileSystemException('One or both ARB files do not exist');
    }

    final arb1 = jsonDecode(file1.readAsStringSync()) as Map<String, dynamic>;
    final arb2 = jsonDecode(file2.readAsStringSync()) as Map<String, dynamic>;

    // Extract locales
    final locale1 =
        arb1['@@locale'] as String? ?? _extractLocaleFromPath(arbFile1Path);
    final locale2 =
        arb2['@@locale'] as String? ?? _extractLocaleFromPath(arbFile2Path);

    // Create Excel workbook and use default sheet
    var excel = Excel.createExcel();
    var sheet = excel[excel.sheets.keys.first];

    // Add headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'keys';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'description';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        locale1;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        locale2;

    // Process each key
    final keys = arb1.keys
        .where((key) => !key.startsWith('@') && key != '@@locale')
        .toList()
      ..sort(); // Sort keys for consistency

    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      final rowIndex = i + 1; // +1 because row 0 is headers

      // Add key
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = key;

      // Add description
      final description = (arb1['@$key']
              as Map<String, dynamic>?)?['description'] as String? ??
          (arb2['@$key'] as Map<String, dynamic>?)?['description'] as String? ??
          '';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = description;

      // Add values
      final value1 = arb1[key].toString();
      final value2 = arb2[key]?.toString() ?? '';

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = value1;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = value2;
    }

    // Set column widths for better readability
    for (var col = 0; col < 4; col++) {
      var colWidth = col == 0 ? 30.0 : 40.0;
      sheet.setColWidth(col, colWidth);
    }

    // Save the Excel file
    final outputFile = File(outputPath);
    outputFile.writeAsBytesSync(excel.save()!);

    print('Successfully generated Excel file at $outputPath');
    print('Converted ${keys.length} keys from $locale1 and $locale2');
  }

  /// Extracts locale from ARB file path (e.g., "app_en.arb" -> "en")
  static String _extractLocaleFromPath(String path) {
    final filename = path.split('/').last;
    final match = RegExp(r'app_(\w+)\.arb$').firstMatch(filename);
    return match?.group(1) ?? 'unknown';
  }
}
