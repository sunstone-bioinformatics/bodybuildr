# Gradient and stripe fills

Fills for \[box_style()\] and \[bb_placeholder()\].

## Usage

``` r
gradient_fill(colors, stops = NULL, dir = "lr")

stripe_fill(colors = c("panel", "panel_alt"), angle = 45, width = 8/96)
```

## Arguments

- colors:

  Colours (theme names allowed). Two or more for gradients; exactly two
  for stripes.

- stops:

  Optional gradient stops in \`\[0, 1\]\`.

- dir:

  Gradient direction: \`"lr"\`, \`"rl"\`, \`"tb"\`, \`"bt"\`,
  \`"tlbr"\`, \`"bltr"\`, \`"trbl"\` or \`"brtl"\`.

- angle:

  Stripe angle in degrees from horizontal (0 \< angle \< 180).

- width:

  Stripe width (\`grid::unit\` or inches). Gaps have the same width.

## Value

A \`bb_fill\` object.

## Details

\`gradient_fill()\` uses grid's linear gradients (R \>= 4.1 on a device
that supports them, such as \`cairo_pdf()\`); elsewhere it falls back to
the first colour.

\`stripe_fill()\` draws diagonal bands as clipped polygons, so it works
on every device. The first colour is the ground, the second the stripes.

## Examples

``` r
gradient_fill(c("#2f6cab", "#173052"))
#> $type
#> [1] "gradient"
#> 
#> $colors
#> [1] "#2f6cab" "#173052"
#> 
#> $stops
#> NULL
#> 
#> $dir
#> [1] "lr"
#> 
#> attr(,"class")
#> [1] "bb_fill"
stripe_fill(c("panel", "panel_alt"), angle = 45, width = unit(8, "pt"))
#> $type
#> [1] "stripes"
#> 
#> $colors
#> [1] "panel"     "panel_alt"
#> 
#> $angle
#> [1] 45
#> 
#> $width
#> [1] 0.110696
#> 
#> attr(,"class")
#> [1] "bb_fill"
```
