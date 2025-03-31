import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';

import '../models/arb/arb_file.dart';
import '../models/settings/package_settings.dart';
import 'file_writer/file_writer.dart';
import 'validation/validator.dart';

/// A service which generates arb files from Excel
abstract class ARBGenerator {
  /// Generates output arb files from an Excel file
  static void generate(
    PackageSettings packageSettings,
  ) {
    // check that the file exists
    final file = File(packageSettings.inputFilepath);
    Validator.validateFile(file);

    // File is valid, state progress
    print('Loading Excel file ${packageSettings.inputFilepath}...');

    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.sheets[excel.getDefaultSheet()];

    if (sheet == null) {
      print('Error: No sheet found in Excel file');
      exit(1);
    }

    // Get header row to determine languages
    final headerRow = sheet.row(0);
    final supportedLanguages = headerRow
        .sublist(2)
        .map((cell) => cell?.value.toString() ?? '')
        .toList();
    Validator.validateSupportedLanguages(supportedLanguages);

    print('Locales $supportedLanguages determined.');

    // Get all rows except header
    final rows = sheet.rows.sublist(1);
    print('Parsing ${rows.length} key(s)...');

    final encoder = JsonEncoder.withIndent('  ');

    // Process each language
    for (var langIndex = 0;
        langIndex < supportedLanguages.length;
        langIndex++) {
      final supportedLanguage = supportedLanguages[langIndex];
      final content = _generateARBFile(
        language: supportedLanguage,
        keys: rows.map((row) => row[0]?.value.toString() ?? '').toList(),
        values: rows
            .map((row) => row[langIndex + 2]?.value.toString() ?? '')
            .toList(),
        defaultValues:
            rows.map((row) => row[2]?.value.toString() ?? '').toList(),
        descriptions:
            rows.map((row) => row[1]?.value.toString() ?? '').toList(),
      );

      var prettyContent = encoder.convert(content.toJson());
      // convert turns \n into \\n
      prettyContent = prettyContent.replaceAll('\\\\', '\\');

      // write output file
      final path =
          '${packageSettings.outputDirectory}/${packageSettings.filenamePrepend}$supportedLanguage.arb';
      FileWriter().write(
        contents: prettyContent,
        path: path,
      );

      print('Generated $path');
    }

    print('All done!');
  }
}

ARBFile _generateARBFile({
  required String language,
  required List<String> keys,
  required List<String> values,
  required List<String> defaultValues,
  List<String>? descriptions,
}) {
  if (keys.length != values.length && keys.length != defaultValues.length) {
    print('Error! Mismatch number of keys and values');
    exit(0);
  }

  final messages = <Message>[];
  for (var i = 0; i < keys.length; i++) {
    final value = i < values.length && values[i].isNotEmpty
        ? values[i]
        : defaultValues[i];
    messages.add(Message(
      key: keys[i],
      value: value,
      description: descriptions?[i],
    ));
  }

  return ARBFile(locale: language, messages: messages);
}
