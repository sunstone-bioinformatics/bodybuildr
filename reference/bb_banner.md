# Banner

A full-bleed coloured band with logos on the left, an optional thin
divider, a title and a subtitle, and an optional accent strip
underneath. Place it as the first block of a page (or as the page
header), where it spans the whole page width.

## Usage

``` r
bb_banner(title, subtitle = NULL, logo = NULL, style = banner_style())
```

## Arguments

- title:

  Title text.

- subtitle:

  Optional subtitle text.

- logo:

  \`NULL\`, or one logo or a list of logos placed side by side. Each
  logo is a png/jpg path, a numeric array/raster, or a grob (a grob uses
  its \`"width_in"\` attribute, else it is drawn square).

- style:

  A \[banner_style()\].

## Value

A full-bleed block.

## Examples

``` r
bb_banner("Immunization Profile", "Argentina, 2025")
#> <bb_banner> (full bleed)
```
