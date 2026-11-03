# Export pages to PDF

Writes one page, a \[bb_document()\], or a list of pages to a single PDF
file. Each page is drawn from its top-left corner; headers and footers
get their \`{page}\` / \`{pages}\` numbers here.

## Usage

``` r
export_pdf(x, file = "bodybuildr.pdf", debug = FALSE)
```

## Arguments

- x:

  A \[bb_page()\], a \[bb_document()\], a list of pages (\`NULL\`s are
  dropped), or a single block (exported on a default page).

- file:

  Output path.

- debug:

  Outline every block's box, for layout work.

## Value

The output path, invisibly.

## Details

\`export_pdf()\` uses \`cairo_pdf()\` when Cairo is available, for full
UTF-8 support and installed font weights. Otherwise it falls back to
\`pdf()\` with a message.

\*\*Cairo availability by platform:\*\* - \*\*Windows:\*\* bundled with
R. - \*\*Linux:\*\* usually present; install \`libcairo2-dev\` if
missing. - \*\*macOS:\*\* requires XQuartz
(\<https://www.xquartz.org\>). After installing, restart R and check
\`capabilities("cairo")\`.

All pages must share one page size.

## Examples

``` r
f <- tempfile(fileext = ".pdf")
export_pdf(bb_page(bb_section_header("Hello"), "World"), f)
```
