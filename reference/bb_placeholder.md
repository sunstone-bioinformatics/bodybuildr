# Placeholder panel

A patterned panel (diagonal stripes by default) with a centred sentence,
for content a data source doesn't provide. Flexible by default, so it
takes the height of its siblings in \[bb_cols()\].

## Usage

``` r
bb_placeholder(
  text,
  fill = stripe_fill(),
  height = NULL,
  style = NULL,
  label_fill = "panel",
  label_width = 0.8,
  label_padding = unit(c(6, 10, 6, 10), "pt")
)
```

## Arguments

- text:

  Sentence shown on the panel.

- fill:

  Panel fill: \[stripe_fill()\], a colour, or \[gradient_fill()\].

- height:

  \`grid::unit\`, inches, or \`NULL\` for flexible.

- style:

  Text style (or role name); default role \`placeholder\`.

- label_fill:

  Fill behind the sentence (theme names allowed); \`NA\` for none.

- label_width:

  Width of the sentence box as a fraction of the panel.

- label_padding:

  Padding around the sentence.

## Value

A block.

## Examples

``` r
bb_placeholder("This country does not report subnational data.", height = 2)
#> <bb_placeholder>
```
