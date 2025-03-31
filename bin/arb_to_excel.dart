import 'dart:io';
import 'package:arb_generator_reworked/src/services/arb_to_excel_converter.dart';

void main(List<String> args) {
  if (args.length < 3) {
    print(
        'Usage: dart run bin/arb_to_excel.dart <arb_file1> <arb_file2> <output_xlsx> [sheet_name]');
    print(
        'Example: dart run bin/arb_to_excel.dart input/arb/app_da.arb input/arb/app_en.arb output/translations.xlsx Sheet1');
    exit(1);
  }

  final arbFile1 = args[0];
  final arbFile2 = args[1];
  final outputExcel = args[2];

  try {
    ARBToExcelConverter.convert(
      arbFile1Path: arbFile1,
      arbFile2Path: arbFile2,
      outputPath: outputExcel,
    );
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
