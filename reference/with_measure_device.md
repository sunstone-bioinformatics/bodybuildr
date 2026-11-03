# Evaluate code on bodybuildr's measuring device

Text and grob sizes depend on the active graphics device. bodybuildr
measures on a hidden PDF device of the same kind \[export_pdf()\] writes
with, so measurements match the exported file and no \`Rplots.pdf\` is
created. The caller's active device is restored afterwards. During
\[export_pdf()\] the export device itself is used.

## Usage

``` r
with_measure_device(expr)
```

## Arguments

- expr:

  Code that converts units or measures grobs.

## Value

The value of \`expr\`.

## Examples

``` r
with_measure_device(
  grid::convertWidth(grid::stringWidth("Hello"), "in", valueOnly = TRUE)
)
#> [1] 0.4027778
```
