# Variables
COVER = assets/cover.jpg
COVER_SMALL = assets/cover_small.jpg
METADATA = assets/epub.metadata.yaml
EPUB_HTML = assets/epub.templete.html
EPUB_CSS = target/epub.css
HEADER_TEX = assets/pdf.header.tex
OUTPUT_DIR = target
PDF_OUTPUT = $(OUTPUT_DIR)/effective-go-zh-en.pdf
TEX_OUTPUT = $(OUTPUT_DIR)/effective-go-zh-en.tex
EPUB_OUTPUT = $(OUTPUT_DIR)/effective-go-zh-en.epub
NPM = npm

# Source files in order
CONTENTS = contents/01_Overview.md \
           contents/02_Formatting.md \
           contents/03_Commentary.md \
           contents/04_Names.md \
           contents/05_Semicolons.md \
           contents/06_Control_Structures.md \
           contents/07_Functions.md \
           contents/08_Data.md \
           contents/09_Initialization.md \
           contents/10_Methods.md \
           contents/11_Interfaces_and_Other_Types.md \
           contents/12_The_Blank_Identifier.md \
           contents/13_Embedding.md \
           contents/14_Concurrency.md \
           contents/15_Errors.md \
           contents/16_A_Web_Server.md

# Pandoc common options
PANDOC_COMMON = --metadata-file=$(METADATA) \
                --toc \
                --toc-depth=2 \
                --syntax-highlighting assets/catppuccin_latte.theme

# Pandoc PDF options
PANDOC_PDF_OPTS = $(PANDOC_COMMON) \
                  --pdf-engine=xelatex \
                  -f markdown-raw_tex \
                  --top-level-division=chapter \
                  --include-in-header $(HEADER_TEX) \
                  -V documentclass=article \
                  -V papersize=a4 \
                  -V geometry:"top=2cm, bottom=1.5cm, left=2cm, right=2cm" \
                  -V fontsize=12pt \
                  -V mainfont="LXGW WenKai" \
                  -V monofont="Maple Mono NF CN" \
                  -V CJKmainfont="LXGW WenKai" \
                  -V urlcolor=NavyBlue \
                  -V numbersections=true \
                  -V secnumdepth=3

# Pandoc EPUB options
PANDOC_EPUB_OPTS = $(PANDOC_COMMON) \
                   --template=$(EPUB_HTML) \
                   --css=$(EPUB_CSS) \
                   --epub-metadata=$(METADATA) \
                   --epub-cover-image=$(COVER) \
                   --split-level=2 \
                   -M document-css=true

# Default target
.PHONY: all
all: pdf epub

# Create output directory
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Build PDF
.PHONY: pdf
pdf: $(OUTPUT_DIR)
	@echo "Building PDF..."
	pandoc $(CONTENTS) \
	       $(PANDOC_PDF_OPTS) \
	       -o $(PDF_OUTPUT)
	@echo "✅ PDF created at $(PDF_OUTPUT)"

.PHONY: tex
tex: $(OUTPUT_DIR)
	@echo "Building LaTeX..."
	pandoc $(CONTENTS) \
	       $(PANDOC_PDF_OPTS) \
	       -s -o $(TEX_OUTPUT)
	@echo "✅ LaTeX created at $(TEX_OUTPUT)"

# Build EPUB
.PHONY: epub
epub: $(OUTPUT_DIR) css
	@echo "Building EPUB..."
	pandoc $(CONTENTS) \
	       $(PANDOC_EPUB_OPTS) \
	       -o $(EPUB_OUTPUT)
	@echo "✅ EPUB created at $(EPUB_OUTPUT)"

# Install dependencies
.PHONY: deps
deps: node_modules/.npm-install

node_modules/.npm-install: package.json
	@echo "Installing dependencies..."
	$(NPM) install
	@touch node_modules/.npm-install

# Build CSS from Tailwind
.PHONY: css
css: $(OUTPUT_DIR) deps
	@echo "Building CSS from Tailwind..."
	$(NPM) run buildcss
	@echo "✅ CSS created at $(EPUB_CSS)"

# Clean build artifacts
.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR)

# Clean all generated files including node_modules
.PHONY: cleandeps
cleandeps: clean
	rm -rf node_modules

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all       - Build both PDF and EPUB (default)"
	@echo "  pdf       - Build PDF only"
	@echo "  epub      - Build EPUB only"
	@echo "  deps      - Install dependencies"
	@echo "  css       - Build CSS from Tailwind (legacy)"
	@echo "  clean     - Remove build artifacts"
	@echo "  distclean - Remove build artifacts and node_modules"
	@echo "  help      - Show this help message"
