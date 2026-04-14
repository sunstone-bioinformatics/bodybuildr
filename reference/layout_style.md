# Define a row layout style

Public dispatcher for row layout constructors. Use this when you want
one consistent entrypoint across row types while keeping row-specific
geometry validated by the underlying specialized helper.

## Usage

``` r
layout_style(type, ...)
```

## Arguments

- type:

  Layout family to construct.

- ...:

  Passed through to the matching specialized layout constructor.

## Value

A row-specific layout list validated by the matching constructor.

## Details

Supported \`type\` values: - \`"banner"\` - \`"columns"\` /
\`"column"\` - \`"three_panel"\` / \`"three-panel"\` / \`"three
panel"\` - \`"subtitle"\`
