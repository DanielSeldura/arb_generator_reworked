# ARB Generator

A Dart tool for bi-directional conversion between ARB and Excel files. This is a focused fork of [arb_generator](https://pub.dev/packages/arb_generator) by [James Leahy (defuncart)](https://github.com/defuncart), modified to work exclusively with Excel files for better handling of multi-line text and complex translations.

## Features

- Convert ARB files to Excel format for easy translation management
- Convert Excel files back to ARB format
- Generate Excel templates with example translations
- Preserve descriptions and metadata
- Support for multi-line text and complex placeholders
- Maintain alphabetical ordering of keys

## Prerequisites

This tool requires Dart SDK >=3.0.0. We recommend using [FVM](https://fvm.app) for version management:

```bash
# Install FVM if you haven't already
dart pub global activate fvm

# Use Dart 3.0.0 or higher
fvm install 3.0.0
fvm use 3.0.0
```

## Installation

### Option 1: Use Pre-compiled Binary

Download the latest binary from the releases page and add it to your PATH.

### Option 2: Build from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/arb_generator.git
cd arb_generator
```

2. Install dependencies:
```bash
fvm dart pub get
```

3. (Optional) Build the binary:
```bash
# Using make (if available)
make build

# Or using dart directly
dart compile exe bin/arb_generator.dart -o bin/arb_generator
```

## Usage

### Using Make (Recommended if Available)

```bash
# Show available commands
make help

# Generate template with default locales (en,da)
make template

# Generate template with specific locales
make template LOCALES=en,da

# Convert Excel to ARB
make excel-to-arb FILE=input.xlsx

# Convert ARB to Excel
make arb-to-excel

# Clean output directories
make clean
```

### Using Direct Commands

#### Generate Excel Template

```bash
# Using binary
./bin/arb_generator template run/input/translations.xlsx en,da

# Using dart run
dart run bin/generate_excel_template.dart run/input/translations.xlsx en,da
```

#### Convert Excel to ARB

```bash
# Using binary
./bin/arb_generator excel-to-arb input.xlsx output/arb

# Using dart run
dart run bin/excel_to_arb.dart input.xlsx output/arb
```

#### Convert ARB to Excel

```bash
# Using binary
./bin/arb_generator arb-to-excel input/app_da.arb input/app_en.arb output/translations.xlsx

# Using dart run
dart run bin/arb_to_excel.dart input/app_da.arb input/app_en.arb output/translations.xlsx
```

## Excel File Format

The Excel file should have the following structure:

| keys | description | en | da |
|------|-------------|----|----|
| welcome | Welcome message | Welcome! | Velkommen! |
| intro | Multi-line intro | First line\nSecond line | Første linje\nAnden linje |
| placeholder | With placeholder | Hello {name}! | Hej {name}! |

- First column must contain translation keys
- Second column contains optional descriptions
- Subsequent columns contain translations for each locale
- Header row should contain locale codes (e.g., "en", "da")

## Directory Structure

```
run/
├── input/
│   └── arb/          # Input ARB files
└── output/
    └── arb/          # Generated ARB files
```

## Contributing

Found a bug? Please open an issue! Want to contribute? Fork the repo and submit a PR!

## License

This project is licensed under the MIT License - see LICENSE file. Original work by [James Leahy (defuncart)](https://github.com/defuncart).

```
