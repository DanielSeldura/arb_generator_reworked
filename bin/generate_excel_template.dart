import 'dart:io';
import 'package:arb_generator_reworked/src/services/excel_template_generator.dart';

void main(List<String> args) {
  if (args.isNotEmpty && args[0] == '--help') {
    printUsage();
    exit(0);
  }

  final outputExcel = args.isNotEmpty ? args[0] : 'run/input/translations.xlsx';
  final locales = args.length > 1 ? args[1].split(',') : null;

  try {
    ExcelTemplateGenerator.generate(
      outputPath: outputExcel,
      locales: locales,
    );
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void printUsage() {
  print(
      'Usage: dart run bin/generate_excel_template.dart [output_xlsx] [locale1,locale2,...]');
  print('');
  print('Arguments:');
  print(
      '  output_xlsx   Path to save the Excel template (default: run/input/translations.xlsx)');
  print(
      '  locales       Comma-separated list of locale codes (default: en,da)');
  print('');
  print('Example:');
  print('  dart run bin/generate_excel_template.dart');
  print(
      '  dart run bin/generate_excel_template.dart run/input/translations.xlsx en,es,fr');
}
