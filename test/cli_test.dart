import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  final testDir = 'test_output_cli';
  final inputDir = path.join(testDir, 'input');
  final outputDir = path.join(testDir, 'output');
  final arbDir = path.join(outputDir, 'arb');
  final binPath =
      path.join(Directory.current.path, 'bin', 'arb_generator.dart');

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

  Future<ProcessResult> runCommand(List<String> args) async {
    return await Process.run(
      'dart',
      ['run', binPath, ...args],
      workingDirectory: Directory.current.path,
    );
  }

  group('CLI Commands Tests', () {
    test('shows help when no arguments provided', () async {
      final result = await runCommand([]);
      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('ARB Generator'));
      expect(result.stdout.toString(), contains('Usage:'));
    });

    test('shows help with --help flag', () async {
      final result = await runCommand(['--help']);
      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('ARB Generator'));
      expect(result.stdout.toString(), contains('Usage:'));
    });

    test('shows template command help', () async {
      final result = await runCommand(['template', '--help']);
      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('Generate an Excel template'));
    });

    test('shows excel-to-arb command help', () async {
      final result = await runCommand(['excel-to-arb', '--help']);
      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(),
          contains('Convert Excel file to ARB files'));
    });

    test('shows arb-to-excel command help', () async {
      final result = await runCommand(['arb-to-excel', '--help']);
      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(),
          contains('Convert ARB files to Excel file'));
    });

    test('fails with unknown command', () async {
      final result = await runCommand(['unknown-command']);
      expect(result.exitCode, equals(1));
      expect(result.stderr.toString(), contains('Error: Unknown command'));
    });

    test('template command creates Excel file', () async {
      final outputFile = path.join(inputDir, 'template.xlsx');
      final result = await runCommand(
          ['template', path.join('run', 'input', 'template.xlsx')]);
      expect(result.exitCode, equals(0));
      expect(File(path.join('run', 'input', 'template.xlsx')).existsSync(),
          isTrue);
    });

    test('template command fails with invalid output path', () async {
      final result =
          await runCommand(['template', 'invalid/path/template.xlsx']);
      expect(result.exitCode, equals(1));
      expect(
          result.stderr.toString(),
          contains(
              'Error: Output Excel file must be in the run directory structure'));
    });

    test('excel-to-arb command fails with missing arguments', () async {
      final result = await runCommand(['excel-to-arb']);
      expect(result.exitCode, equals(1));
      expect(result.stderr.toString(),
          contains('Error: Missing required arguments'));
    });

    test('arb-to-excel command fails with missing arguments', () async {
      final result = await runCommand(['arb-to-excel']);
      expect(result.exitCode, equals(1));
      expect(result.stderr.toString(),
          contains('Error: Missing required arguments'));
    });

    test('excel-to-arb command works with valid arguments', () async {
      // First create a template
      final templateFile = path.join('run', 'input', 'test_template.xlsx');
      await runCommand(['template', templateFile]);

      // Then try to convert it
      final result = await runCommand(
          ['excel-to-arb', templateFile, path.join('run', 'output', 'arb')]);
      expect(result.exitCode, equals(0));
      expect(File(path.join('run', 'output', 'arb', 'app_en.arb')).existsSync(),
          isTrue);
      expect(File(path.join('run', 'output', 'arb', 'app_da.arb')).existsSync(),
          isTrue);
    });

    test('arb-to-excel command works with valid arguments', () async {
      // Create test ARB files
      final enArbFile = path.join('run', 'input', 'arb', 'app_en.arb');
      final daArbFile = path.join('run', 'input', 'arb', 'app_da.arb');
      final outputExcel =
          path.join('run', 'output', 'translations_output.xlsx');

      File(enArbFile)
        ..createSync(recursive: true)
        ..writeAsStringSync('''
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

      File(daArbFile)
        ..createSync(recursive: true)
        ..writeAsStringSync('''
{
  "greeting": "Hej",
  "farewell": "Farvel",
  "@greeting": {
    "description": "A greeting message"
  },
  "@farewell": {
    "description": "A farewell message"
  }
}''');

      final result =
          await runCommand(['arb-to-excel', enArbFile, daArbFile, outputExcel]);
      expect(result.exitCode, equals(0));
      expect(File(outputExcel).existsSync(), isTrue);
    });
  });
}
