import 'dart:io';

import '../../configs/constants.dart' as constants;
import '../../extensions/file_extensions.dart';
import '../../extensions/string_extensions.dart';

abstract class Validator {
  /// Validates whether [file] is valid
  ///
  /// If any error occurs, process is terminated
  static void validateFile(File file) {
    // check that the file exists
    if (!file.existsSync()) {
      print('File ${file.path} does not exist!');
      exit(1);
    }

    // check that the file extension is correct
    if (!file.hasValidExtension) {
      print(
        'File ${file.path} has extension ${file.extensionType} which is not supported!',
      );
      exit(1);
    }
  }

  /// Validates whether [supportedLanguages] are valid
  ///
  /// If any error occurs, process is terminated
  static void validateSupportedLanguages(List<String> supportedLanguages) {
    if (supportedLanguages.isEmpty) {
      print('No languages found in Excel file header row');
      exit(1);
    }

    for (final supportedLanguage in supportedLanguages) {
      if (!supportedLanguage.isValidLocale) {
        print(
            '$supportedLanguage isn\'t a valid locale. Expected locale of the form "en" or "en_US".');
        exit(1);
      }

      final languageCode = supportedLanguage.split('_').first;
      if (!constants.flutterLocalizedLanguages.contains(languageCode)) {
        print('$languageCode isn\'t supported by default in Flutter.');
        print(
            'Please see https://flutter.dev/docs/development/accessibility-and-localization/internationalization#adding-support-for-a-new-language for info on how to add required classes.');
      }
    }
  }

  /// Validates whether a key is valid for use in ARB files
  ///
  /// If any error occurs, process is terminated
  static void validateKey(String key) {
    if (constants.reservedWords.contains(key)) {
      print('Key $key is a reserved keyword in Dart and is thus invalid.');
      exit(1);
    }

    if (constants.types.contains(key)) {
      print('Key $key is a type in Dart and is thus invalid.');
      exit(1);
    }

    if (!key.isValidVariableName) {
      print('Key $key is invalid. Expected key in the form lowerCamelCase.');
      exit(1);
    }
  }
}
