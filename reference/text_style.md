# Define a text style

A text style lists only the properties it changes. Anything left
\`NULL\` is inherited from \`base\` (a theme role name or another text
style), or from the role the component uses by default. So
\`text_style(weight = 600)\` passed to \[bb_text()\] means "body text,
semibold", and the same style passed as a table header style means
"table header, semibold".

## Usage

``` r
text_style(
  base = NULL,
  size = NULL,
  weight = NULL,
  color = NULL,
  family = NULL,
  italic = NULL,
  lineheight = NULL,
  case = NULL
)
```

## Arguments

- base:

  A theme role name (e.g. \`"note"\`) or another \`text_style()\` to
  inherit from.

- size:

  Font size in points.

- weight:

  Font weight, numeric (100-900) or a name (\`"regular"\`,
  \`"semibold"\`, \`"bold"\`, ...).

- color:

  Text colour: an R colour or a theme colour name.

- family:

  Font family.

- italic:

  \`TRUE\` for italic.

- lineheight:

  Line height as a multiple of the font size.

- case:

  Letter case applied to plain text: \`"none"\`, \`"upper"\`,
  \`"lower"\` or \`"title"\`.

## Value

A \`bb_text_style\` object.

## Details

\*\*Weights.\*\* \`weight\` takes a number (100-900) or a name such as
\`"semibold"\`. 400 and 700 use the family's regular and bold faces.
Other weights are looked up with systemfonts: if a face with that weight
is installed (for example "Source Sans 3 Semibold"), its family name is
used, which \`cairo_pdf()\` resolves through fontconfig. Otherwise
bodybuildr falls back to bold (600 and above) or regular, with a
one-time message.

## Examples

``` r
text_style(size = 12, weight = "semibold", color = "muted")
#> <text_style> 
#>  size: 12
#>  weight: 600
#>  color: muted
text_style("note", italic = TRUE)
#> <text_style> base: note 
#>  italic: TRUE
```
