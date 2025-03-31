import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:excel/excel.dart';
import 'package:arb_generator_reworked/src/services/excel_template_generator.dart';
import 'package:arb_generator_reworked/src/services/excel_to_arb_converter.dart';
import 'package:arb_generator_reworked/src/services/arb_to_excel_converter.dart';

void main() {
  // Test directory setup
  final testDir = 'test_output';
  final inputDir = path.join(testDir, 'input');
  final outputDir = path.join(testDir, 'output');
  final arbDir = path.join(outputDir, 'arb');

  setUp(() {
    // Create test directories
    Directory(inputDir).createSync(recursive: true);
    Directory(arbDir).createSync(recursive: true);
  });

  tearDown(() {
    // Clean up test directories
    if (Directory(testDir).existsSync()) {
      Directory(testDir).deleteSync(recursive: true);
    }
  });

  group('Template Generation Tests', () {
    test('generates template with default locales', () {
      final outputFile = path.join(inputDir, 'template.xlsx');

      ExcelTemplateGenerator.generate(
        outputPath: outputFile,
        locales: null,
      );

      expect(File(outputFile).existsSync(), isTrue);

      // Verify Excel content
      final bytes = File(outputFile).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.sheets[excel.sheets.keys.first]!;

      // Verify headers
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
              .value
              .toString(),
          equals('keys'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
              .value
              .toString(),
          equals('description'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
              .value
              .toString(),
          equals('en'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
              .value
              .toString(),
          equals('da'));
    });

    test('generates template with custom locales', () {
      final outputFile = path.join(inputDir, 'custom_template.xlsx');
      final customLocales = ['en', 'es', 'fr'];

      ExcelTemplateGenerator.generate(
        outputPath: outputFile,
        locales: customLocales,
      );

      expect(File(outputFile).existsSync(), isTrue);

      final bytes = File(outputFile).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.sheets[excel.sheets.keys.first]!;

      // Verify headers
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
              .value
              .toString(),
          equals('keys'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
              .value
              .toString(),
          equals('description'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
              .value
              .toString(),
          equals('en'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
              .value
              .toString(),
          equals('es'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
              .value
              .toString(),
          equals('fr'));
    });
  });

  group('Excel to ARB Conversion Tests', () {
    late String templateFile;

    setUp(() {
      templateFile = path.join(inputDir, 'test_template.xlsx');
      ExcelTemplateGenerator.generate(
        outputPath: templateFile,
        locales: ['en', 'es'],
      );

      // Add test data to Excel
      final bytes = File(templateFile).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.sheets[excel.sheets.keys.first]!;

      // Add test translations
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = 'greeting';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
          .value = 'A greeting message';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
          .value = 'Hello';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1))
          .value = 'Hola';

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
          .value = 'farewell';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
          .value = 'A farewell message';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2))
          .value = 'Goodbye';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2))
          .value = 'Adiós';

      // Save modified Excel file
      File(templateFile).writeAsBytesSync(excel.save()!);
    });

    test('converts Excel to ARB files correctly', () {
      ExcelToARBConverter.convert(
        excelPath: templateFile,
        outputDir: arbDir,
      );

      final enArb = File(path.join(arbDir, 'app_en.arb'));
      final esArb = File(path.join(arbDir, 'app_es.arb'));

      expect(enArb.existsSync(), isTrue);
      expect(esArb.existsSync(), isTrue);

      final enContent = enArb.readAsStringSync();
      final esContent = esArb.readAsStringSync();

      expect(enContent.contains('"greeting": "Hello"'), isTrue);
      expect(enContent.contains('"farewell": "Goodbye"'), isTrue);
      expect(esContent.contains('"greeting": "Hola"'), isTrue);
      expect(esContent.contains('"farewell": "Adiós"'), isTrue);
    });
  });

  group('ARB to Excel Conversion Tests', () {
    late String enArbPath;
    late String esArbPath;

    setUp(() {
      enArbPath = path.join(arbDir, 'app_en.arb');
      esArbPath = path.join(arbDir, 'app_es.arb');

      // Create test ARB files
      File(enArbPath).writeAsStringSync('''
{
  "greeting": "Hello",
  "farewell": "Goodbye",
  "@greeting": {
    "description": "A greeting message"
  },
  "@farewell": {
    "description": "A farewell message"
  }
}''');

      File(esArbPath).writeAsStringSync('''
{
  "greeting": "Hola",
  "farewell": "Adiós",
  "@greeting": {
    "description": "A greeting message"
  },
  "@farewell": {
    "description": "A farewell message"
  }
}''');
    });

    test('converts ARB files to Excel correctly', () {
      final outputExcel = path.join(outputDir, 'output.xlsx');

      ARBToExcelConverter.convert(
        arbFile1Path: enArbPath,
        arbFile2Path: esArbPath,
        outputPath: outputExcel,
      );

      expect(File(outputExcel).existsSync(), isTrue);

      final bytes = File(outputExcel).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.sheets[excel.sheets.keys.first]!;

      // Verify headers
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
              .value
              .toString(),
          equals('keys'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
              .value
              .toString(),
          equals('description'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
              .value
              .toString(),
          equals('en'));
      expect(
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
              .value
              .toString(),
          equals('es'));

      // Verify content
      final cells = sheet.rows.skip(1).toList();
      bool foundGreeting = false;
      bool foundFarewell = false;

      for (var i = 1; i < sheet.maxRows; i++) {
        final key = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
            .value
            ?.toString();
        if (key == 'greeting') {
          expect(
              sheet
                  .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i))
                  .value
                  .toString(),
              equals('Hello'));
          expect(
              sheet
                  .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i))
                  .value
                  .toString(),
              equals('Hola'));
          foundGreeting = true;
        }
        if (key == 'farewell') {
          expect(
              sheet
                  .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i))
                  .value
                  .toString(),
              equals('Goodbye'));
          expect(
              sheet
                  .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i))
                  .value
                  .toString(),
              equals('Adiós'));
          foundFarewell = true;
        }
      }

      expect(foundGreeting, isTrue);
      expect(foundFarewell, isTrue);
    });
  });
}
