# Define a theme

A theme holds the colour palette, the text roles components draw with,
and the status palette used by \[bb_status()\]. Set it once with
\[bb_set_theme()\], or attach it to a \[page_template()\].

## Usage

``` r
bb_theme(
  font = "sans",
  base_size = 9,
  colors = list(),
  text = list(),
  status = c(yes = "#2F7D55", no = "#C2412F", unknown = "#9AA1AA")
)
```

## Arguments

- font:

  Default font family. With systemfonts installed, weights such as 600
  resolve to the matching installed face (see \[text_style()\]).

- base_size:

  Body font size in points.

- colors:

  Named list of colours that override or extend the palette.

- text:

  Named list of \[text_style()\] objects that override or extend the
  text roles. Fields left \`NULL\` keep the role default.

- status:

  Named colours for \`yes\`, \`no\` and \`unknown\`.

## Value

A \`bb_theme\` object.

## Details

\*\*Colours.\*\* Every colour argument in bodybuildr accepts either an R
colour or the name of a theme colour, for example \`"muted"\` or
\`"rule_light"\`. Defaults: \`primary\`, \`accent\`, \`ink\`, \`text2\`,
\`muted\`, \`faint\`, \`rule_strong\`, \`rule_light\`, \`rule_faint\`,
\`panel\`, \`panel_alt\`, \`on_primary\`, \`on_primary_muted\`. Add your
own names freely.

\*\*Text roles.\*\* Components take \`style = NULL\` and fall back to a
role: \`body\`, \`table_body\`, \`note\`, \`small\`, \`subheading\`,
\`section\`, \`refs\`, \`title\`, \`subtitle\`, \`running\`,
\`running_right\`, \`table_header\`, \`legend\`, \`footer\`,
\`status_label\`, \`placeholder\`. Pass a role name as \`style\`
anywhere (\`bb_text(x, style = "note")\`), override a role through
\`text\`, or add new roles.

Default sizes follow a 12px = 9pt body scale; \`base_size\` scales them
all.

## Examples

``` r
th <- bb_theme(font = "sans", colors = list(primary = "#123456"),
               text = list(note = text_style(size = 8)))
th$colors$primary
#> [1] "#123456"
```
