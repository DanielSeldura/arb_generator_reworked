# ARB Generator Makefile

.PHONY: help template excel-to-arb arb-to-excel build clean test test-all test-unit test-cli

# Default directories
RUN_DIR = run
INPUT_DIR = $(RUN_DIR)/input
OUTPUT_DIR = $(RUN_DIR)/output
ARB_DIR = $(OUTPUT_DIR)/arb

# Binary and defaults
BINARY = bin/arb_generator
TEMPLATE_FILE = $(INPUT_DIR)/translations.xlsx
LOCALES ?= en,da

# Default target shows help
help:
	@echo "ARB Generator - Excel ↔ ARB conversion tool"
	@echo ""
	@echo "Usage:"
	@echo "  make build                        - Build executable (do this first)"
	@echo "  make template [LOCALES=en,da]     - Generate Excel template"
	@echo "  make excel-to-arb FILE=<xlsx>     - Convert Excel to ARB"
	@echo "  make arb-to-excel LOCALES=en,da   - Convert ARB to Excel"
	@echo "  make clean                        - Clean output directories"
	@echo "  make test                         - Run all tests"
	@echo "  make test-unit                    - Run unit tests"
	@echo "  make test-cli                     - Run CLI tests"
	@echo ""
	@echo "Examples:"
	@echo "  make build && make template       # Build and create template"
	@echo "  make template LOCALES=en,es,fr    # Template with specific locales"
	@echo "  make excel-to-arb FILE=input.xlsx # Convert specific Excel file"
	@echo "  make arb-to-excel                 # Convert latest ARB files"

# Build executable
build:
	@echo "Building executable..."
	@dart compile exe bin/arb_generator.dart -o $(BINARY)
	@echo "Executable created at $(BINARY)"

# Generate Excel template
template: check-binary
	@mkdir -p $(INPUT_DIR)/arb $(ARB_DIR)
	@if [ -f "$(BINARY)" ]; then \
		./$(BINARY) template $(TEMPLATE_FILE) $(LOCALES); \
	else \
		dart run bin/generate_excel_template.dart $(TEMPLATE_FILE) $(LOCALES); \
	fi

# Convert Excel to ARB
excel-to-arb: check-binary
	@mkdir -p $(ARB_DIR)
	@if [ -f "$(BINARY)" ]; then \
		if [ -n "$(FILE)" ]; then \
			./$(BINARY) excel-to-arb $(FILE) $(ARB_DIR); \
		else \
			./$(BINARY) excel-to-arb $(TEMPLATE_FILE) $(ARB_DIR); \
		fi \
	else \
		if [ -n "$(FILE)" ]; then \
			dart run bin/excel_to_arb.dart $(FILE) $(ARB_DIR); \
		else \
			dart run bin/excel_to_arb.dart $(TEMPLATE_FILE) $(ARB_DIR); \
		fi \
	fi

# Convert ARB to Excel
arb-to-excel: check-binary
	@mkdir -p $(OUTPUT_DIR)
	@if [ -f "$(BINARY)" ]; then \
		./$(BINARY) arb-to-excel \
			$(ARB_DIR)/app_da.arb \
			$(ARB_DIR)/app_en.arb \
			$(OUTPUT_DIR)/translations_output.xlsx; \
	else \
		dart run bin/arb_to_excel.dart \
			$(ARB_DIR)/app_da.arb \
			$(ARB_DIR)/app_en.arb \
			$(OUTPUT_DIR)/translations_output.xlsx; \
	fi

# Check if binary exists and warn if not
check-binary:
	@if [ ! -f "$(BINARY)" ]; then \
		echo "Warning: Binary not found. Using 'dart run' instead."; \
		echo "Run 'make build' first for better performance."; \
		echo ""; \
	fi

# Clean output directories
clean:
	@rm -rf $(RUN_DIR)
	@echo "Cleaned $(RUN_DIR) directory"

# Run all tests
test: test-unit test-cli

# Run unit tests
test-unit:
	@echo "Running unit tests..."
	@dart test test/arb_generator_test.dart

# Run CLI tests
test-cli:
	@echo "Running CLI tests..."
	@dart test test/cli_test.dart 