# Text block

Wrapped text that is exactly as tall as its content at the width it is
given.

## Usage

``` r
bb_text(
  x,
  style = NULL,
  markup = c("plain", "markdown", "html"),
  align = c("left", "center", "right"),
  link_color = NULL
)
```

## Arguments

- x:

  Text (character vector, pasted together).

- style:

  A \[text_style()\], a theme role name, or \`NULL\` for \`"body"\`.

- markup:

  \`"plain"\`, \`"markdown"\` or \`"html"\`.

- align:

  Horizontal alignment: \`"left"\`, \`"center"\` or \`"right"\`.

- link_color:

  Colour of links; defaults to the text colour.

## Value

A block.

## Details

\- \`markup = "plain"\` (default) prints the text literally: characters
such as \`\<80 \[link()\] runs are kept. - \`markup = "markdown"\` reads
Markdown: bold, italic, lists, headings, links. - \`markup = "html"\`
passes the gridtext HTML subset (\`\<b\>\`, \`\<i\>\`, \`\<span
style\>\`, \`\<br\>\`, \`\<sup\>\`, \`\<sub\>\`).

A character vector is pasted together without separators, so \`c("Total:
", span("4", weight = 600))\` reads as one line.

## Examples

``` r
bb_text("Values below <80% are flagged.")
#> <bb_text>
bb_text("**Bold** and *italic*", markup = "markdown", style = "note")
#> <bb_text>
```
