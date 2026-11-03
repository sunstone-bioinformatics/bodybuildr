# Mark a block as full bleed

A full-bleed block that sits directly in a \[bb_page()\] spans the whole
page width, ignoring the side margins (for a coloured band, say).
Elsewhere the flag has no effect.

## Usage

``` r
bb_full_bleed(x)
```

## Arguments

- x:

  A block or anything \[as_block()\] accepts.

## Value

The block, flagged.

## Examples

``` r
bb_full_bleed(bb_box(NULL, box_style(fill = "primary", padding = 0.3)))
#> <bb_box> (full bleed)
```
