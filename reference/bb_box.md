# Box around a block

Adds padding, a fill (solid, \[gradient_fill()\] or \[stripe_fill()\]),
a border and a margin around any block. This is the box-spacing band of
the margin model: it never affects page margins or layout gaps.

## Usage

``` r
bb_box(x, style = box_style())
```

## Arguments

- x:

  A block or anything \[as_block()\] accepts. \`NULL\` gives an empty
  box as tall as its padding.

- style:

  A \[box_style()\].

## Value

A block. Flexible when \`x\` is flexible.

## Examples

``` r
bb_box(bb_text("A note", style = "note"), box_style_panel())
#> <bb_box>
```
