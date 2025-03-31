import 'dart:io';
import 'package:excel/excel.dart';

/// A service which generates a sample Excel template for translations
class ExcelTemplateGenerator {
  /// Generates a sample Excel template file with the correct structure
  /// [outputPath] - Path where the Excel template should be saved
  /// [locales] - Optional list of locales to include (defaults to ['en', 'da'])
  static void generate({
    required String outputPath,
    List<String>? locales,
  }) {
    final languageCodes = locales ?? ['en', 'da'];
    if (languageCodes.length < 2) {
      throw ArgumentError('At least two locales are required');
    }

    // Create standard directory structure
    _createDirectoryStructure();

    // Create Excel workbook and use the default sheet
    var excel = Excel.createExcel();
    var sheet = excel[excel.sheets.keys.first];

    // Add headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'keys';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'description';

    // Add locale headers
    for (var i = 0; i < languageCodes.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: 0))
          .value = languageCodes[i];
    }

    // Add sample rows
    _addSampleRow(sheet, 1, 'welcome_message',
        'Welcome message shown on home screen', languageCodes);
    _addSampleRow(sheet, 2, 'user_greeting',
        'Greeting with user name placeholder', languageCodes);
    _addSampleRow(sheet, 3, 'multi_line_text', 'Example of multi-line text',
        languageCodes);
    _addSampleRow(sheet, 4, 'special_chars', 'Text with special characters',
        languageCodes);
    _addSampleRow(sheet, 5, 'placeholder_example', 'Text with placeholders',
        languageCodes);

    // Set column widths for better readability
    final columnCount = 2 + languageCodes.length;
    for (var col = 0; col < columnCount; col++) {
      var colWidth = col == 0 ? 30.0 : 40.0;
      sheet.setColWidth(col, colWidth);
    }

    // Save the Excel file
    final outputFile = File(outputPath);
    outputFile.writeAsBytesSync(excel.save()!);

    print('\nDirectory structure created:');
    print('  run/');
    print('  ├── input/');
    print('  │   └── arb/');
    print('  └── output/');
    print('      └── arb/\n');
    print('Successfully generated Excel template at $outputPath');
    print(
        'Template includes example translations for ${languageCodes.join(", ")}');
    print('\nNext steps:');
    print('1. Fill in your translations in the Excel file');
    print('2. Convert to ARB using:');
    print('   dart run bin/excel_to_arb.dart $outputPath run/output/arb');
  }

  /// Creates the standard directory structure for the project
  static void _createDirectoryStructure() {
    final directories = [
      'run/input/arb',
      'run/output/arb',
    ];

    for (final dir in directories) {
      final directory = Directory(dir);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
    }
  }

  /// Adds a sample row with appropriate examples for each locale
  static void _addSampleRow(Sheet sheet, int rowIndex, String key,
      String description, List<String> locales) {
    // Add key
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = key;

    // Add description
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = description;

    // Add sample translations
    for (var i = 0; i < locales.length; i++) {
      final locale = locales[i];
      final value = _getSampleTranslation(key, locale);
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: i + 2, rowIndex: rowIndex))
          .value = value;
    }
  }

  /// Returns a sample translation based on the key and locale
  static String _getSampleTranslation(String key, String locale) {
    switch (key) {
      case 'welcome_message':
        return locale == 'en'
            ? 'Welcome to our app!'
            : 'Velkommen til vores app!';
      case 'user_greeting':
        return locale == 'en' ? 'Hello, {username}!' : 'Hej, {username}!';
      case 'multi_line_text':
        return locale == 'en'
            ? 'First line\nSecond line\nThird line'
            : 'Første linje\nAnden linje\nTredje linje';
      case 'special_chars':
        return locale == 'en'
            ? 'Special chars: @#\$%&*'
            : 'Specialtegn: @#\$%&*';
      case 'placeholder_example':
        return locale == 'en'
            ? 'You have {count} messages'
            : 'Du har {count} beskeder';
      default:
        return 'Translation needed';
    }
  }
}
