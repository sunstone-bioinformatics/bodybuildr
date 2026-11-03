# Image block

A PNG/JPEG file, numeric array or raster. Without a \`height\`, the
block is as tall as the image at the given width (its natural aspect
ratio).

## Usage

``` r
bb_image(
  src,
  height = NULL,
  fit = c("contain", "fill"),
  align = c("center", "left", "right")
)
```

## Arguments

- src:

  Path to a \`.png\`/\`.jpg\` file, a numeric array, or a raster.

- height:

  \`grid::unit\`, inches, or \`NULL\` for the natural height.

- fit:

  \`"contain"\` keeps the aspect ratio inside the slot; \`"fill"\`
  stretches to the slot.

- align:

  Horizontal position when the image is narrower than its slot:
  \`"left"\`, \`"center"\` or \`"right"\`.

## Value

A block.

## Examples

``` r
img <- array(c(0.2, 0.4, 0.8), dim = c(1, 1, 3))
bb_image(img, height = 0.5)
#> <bb_image>
```
