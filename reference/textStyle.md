# Define a text style (ggplot2 element_text-like)

Convenience helper to create a \`grid::gpar\` with common text
properties.

## Usage

``` r
textStyle(color = "#111111", size = 11, face = "plain", family = "sans")
```

## Arguments

- color:

  Text color.

- size:

  Font size (points, non-negative).

- face:

  Font face (e.g., "plain", "bold", "italic").

- family:

  Font family.

## Value

A \`grid::gpar\` object.

## Details

All numeric arguments must be length-1 and non-negative.
