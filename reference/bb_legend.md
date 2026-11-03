# Inline legend

Keys and labels flow left to right and wrap onto further lines when they
don't fit the width (long translated labels). An optional \`note\` sits
right-aligned on the first line when there is room, otherwise on its own
line below.

## Usage

``` r
bb_legend(
  keys,
  note = NULL,
  align = c("left", "right"),
  style = NULL,
  key_size = 12/96,
  gap = 18/96,
  key_gap = 6/96,
  row_height = NULL,
  wrap = TRUE
)
```

## Arguments

- keys:

  A list of \[legend_key()\]s.

- note:

  Optional note text.

- align:

  \`"left"\` or \`"right"\`.

- style:

  Label text style (\[text_style()\] or role name); defaults to the
  \`legend\` role.

- key_size:

  Key size (\`grid::unit\` or inches). Default 12px.

- gap:

  Space between entries.

- key_gap:

  Space between a key and its label.

- row_height:

  Height of one legend line; by default from the key and label size.

- wrap:

  Wrap onto several lines when needed.

## Value

A block.

## Examples

``` r
bb_legend(list(legend_key("swatch", "<80%", "#C8503F"),
               legend_key("swatch", "95-100%", "#8CC49A")),
          note = "National coverage")
#> <bb_legend>
```
