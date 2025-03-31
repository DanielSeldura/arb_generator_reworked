import 'dart:io';
import 'package:arb_generator_reworked/src/services/excel_to_arb_converter.dart';

void main(List<String> args) {
  if (args.length < 2) {
    print(
        'Usage: dart run bin/excel_to_arb.dart <input_xlsx> <output_dir> [sheet_name]');
    print(
        'Example: dart run bin/excel_to_arb.dart input/translations.xlsx output/arb Sheet1');
    exit(1);
  }

  final inputExcel = args[0];
  final outputDir = args[1];
  final sheetName = args.length > 2 ? args[2] : null;

  try {
    ExcelToARBConverter.convert(
      excelPath: inputExcel,
      outputDir: outputDir,
      sheet: sheetName,
    );
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
