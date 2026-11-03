# Build a custom block

Low-level constructor for blocks. Most users combine the built-in
blocks; use this to wrap a custom drawing that should take part in
layout.

## Usage

``` r
new_block(
  type,
  measure,
  render,
  min_height = NULL,
  natural_width = NULL,
  full_bleed = FALSE,
  ...
)
```

## Arguments

- type:

  Short type name; the block gets class \`bb\_\<type\>\`.

- measure:

  \`function(width)\` returning the height in inches at that width, or
  \`NA\` when the block is flexible (it takes whatever height its
  container gives it).

- render:

  \`function(width, height)\` returning a grob that draws inside a
  viewport of \`width\` x \`height\` inches, anchored top-left.

- min_height:

  Optional \`function(width)\` giving the smallest height a flexible
  block can take. Defaults to 0.

- natural_width:

  Optional \`function(width)\` giving the width the content actually
  uses (for marks and icons that are narrower than their slot).
  Containers use it for horizontal alignment.

- full_bleed:

  When \`TRUE\` and the block is a direct child of a page, it spans the
  full page width, ignoring the side margins.

- ...:

  Extra fields stored on the block.

## Value

A block of class \`c("bb\_\<type\>", "bb_block")\`.

## Examples

``` r
bar <- new_block(
  "bar",
  measure = function(width) 0.1,
  render = function(width, height) grid::rectGrob(gp = grid::gpar(fill = "grey"))
)
measure_block(bar, 2)
#> [1] 0.1inches
```
