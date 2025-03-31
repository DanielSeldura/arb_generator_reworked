import 'dart:io';
import 'package:arb_generator_reworked/src/services/arb_to_excel_converter.dart';
import 'package:arb_generator_reworked/src/services/excel_to_arb_converter.dart';
import 'package:arb_generator_reworked/src/services/excel_template_generator.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) {
  if (args.isEmpty || args[0] == '--help' || args[0] == '-h') {
    printUsage();
    exit(0);
  }

  // Create standard directories if they don't exist
  createDirectories();

  final command = args[0];
  final remainingArgs = args.sublist(1);

  try {
    switch (command) {
      case 'template':
        handleTemplate(remainingArgs);
        break;
      case 'excel-to-arb':
        handleExcelToArb(remainingArgs);
        break;
      case 'arb-to-excel':
        handleArbToExcel(remainingArgs);
        break;
      default:
        printError('Unknown command: $command');
        printUsage();
        exit(1);
    }
  } catch (e) {
    printError('Error: $e');
    exit(1);
  }
}

void createDirectories() {
  Directory('run/input/arb').createSync(recursive: true);
  Directory('run/output/arb').createSync(recursive: true);
}

void handleTemplate(List<String> args) {
  if (args.isNotEmpty && (args[0] == '--help' || args[0] == '-h')) {
    printTemplateUsage();
    exit(0);
  }

  final outputExcel = args.isNotEmpty ? args[0] : 'run/input/translations.xlsx';

  if (!path.isAbsolute(outputExcel) && !outputExcel.startsWith('run/')) {
    printError('Output Excel file must be in the run directory structure');
    exit(1);
  }

  final locales = args.length > 1 ? args[1].split(',') : null;

  ExcelTemplateGenerator.generate(
    outputPath: outputExcel,
    locales: locales,
  );
}

void handleExcelToArb(List<String> args) {
  if (args.isEmpty) {
    printError('Missing required arguments');
    printExcelToArbUsage();
    exit(1);
  }

  if (args[0] == '--help' || args[0] == '-h') {
    printExcelToArbUsage();
    exit(0);
  }

  if (args.length < 2) {
    printError('Missing required arguments');
    printExcelToArbUsage();
    exit(1);
  }

  final inputExcel = args[0];
  final outputDir = args[1];

  // Validate input file exists
  if (!File(inputExcel).existsSync()) {
    printError('Input Excel file does not exist: $inputExcel');
    exit(1);
  }

  // Validate output directory is in run structure
  if (!path.isAbsolute(outputDir) && !outputDir.startsWith('run/')) {
    printError('Output directory must be in the run directory structure');
    exit(1);
  }

  ExcelToARBConverter.convert(
    excelPath: inputExcel,
    outputDir: outputDir,
  );
}

void handleArbToExcel(List<String> args) {
  if (args.isEmpty) {
    printError('Missing required arguments');
    printArbToExcelUsage();
    exit(1);
  }

  if (args[0] == '--help' || args[0] == '-h') {
    printArbToExcelUsage();
    exit(0);
  }

  if (args.length < 3) {
    printError('Missing required arguments');
    printArbToExcelUsage();
    exit(1);
  }

  final arbFile1 = args[0];
  final arbFile2 = args[1];
  final outputExcel = args[2];

  // Validate input files exist
  if (!File(arbFile1).existsSync()) {
    printError('First ARB file does not exist: $arbFile1');
    exit(1);
  }
  if (!File(arbFile2).existsSync()) {
    printError('Second ARB file does not exist: $arbFile2');
    exit(1);
  }

  // Validate output file is in run structure
  if (!path.isAbsolute(outputExcel) && !outputExcel.startsWith('run/')) {
    printError('Output Excel file must be in the run directory structure');
    exit(1);
  }

  ARBToExcelConverter.convert(
    arbFile1Path: arbFile1,
    arbFile2Path: arbFile2,
    outputPath: outputExcel,
  );
}

void printUsage() {
  print('''
ARB Generator - A tool for managing translations between ARB and Excel formats

Usage: arb_generator <command> [options]

Commands:
  template      Generate an Excel template for translations
  excel-to-arb  Convert Excel file to ARB files
  arb-to-excel  Convert ARB files to Excel file

For help on a specific command:
  arb_generator <command> --help

Examples:
  # Generate template
  arb_generator template
  arb_generator template run/input/translations.xlsx en,es,fr

  # Convert Excel to ARB
  arb_generator excel-to-arb run/input/translations.xlsx run/output/arb

  # Convert ARB to Excel
  arb_generator arb-to-excel run/input/arb/app_en.arb run/input/arb/app_da.arb run/output/translations.xlsx
''');
}

void printTemplateUsage() {
  print('''
Generate an Excel template for translations

Usage: arb_generator template [output_xlsx] [locale1,locale2,...]

Arguments:
  output_xlsx   Path to save the Excel template (default: run/input/translations.xlsx)
  locales       Comma-separated list of locale codes (default: en,da)

Examples:
  arb_generator template
  arb_generator template run/input/translations.xlsx en,es,fr
''');
}

void printExcelToArbUsage() {
  print('''
Convert Excel file to ARB files

Usage: arb_generator excel-to-arb <input_xlsx> <output_dir>

Arguments:
  input_xlsx    Path to the Excel file to convert
  output_dir    Directory where ARB files will be generated

Example:
  arb_generator excel-to-arb run/input/translations.xlsx run/output/arb
''');
}

void printArbToExcelUsage() {
  print('''
Convert ARB files to Excel file

Usage: arb_generator arb-to-excel <arb_file1> <arb_file2> <output_xlsx>

Arguments:
  arb_file1     Path to the first ARB file (base language)
  arb_file2     Path to the second ARB file
  output_xlsx   Path where the Excel file will be saved

Example:
  arb_generator arb-to-excel run/input/arb/app_en.arb run/input/arb/app_da.arb run/output/translations.xlsx
''');
}

void printError(String message) {
  stderr.writeln('Error: $message');
}
