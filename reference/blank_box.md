# Construct an intentional empty layout box

Creates a blank layout payload that can be passed into row layout
functions when you want an explicit empty slot in the composition.

## Usage

``` r
blank_box()
```

## Value

An object of class \`"bbdr_blank_box"\` to use as an item in layout
rows.

## Details

Unlike \`NULL\`, which means missing content, \`blank_box()\` means a
deliberate empty layout element that still participates in row geometry.
