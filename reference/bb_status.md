# Status icon

A filled circle with a white check (\`"yes"\`), cross (\`"no"\`) or dash
(\`"unknown"\`), drawn as vectors in the theme status palette,
optionally followed by a label such as "Yes". \`TRUE\`/\`FALSE\` map to
yes/no; \`NA\` and anything else to unknown. Use it as a table cell, in
columns, or anywhere a block goes.

## Usage

``` r
bb_status(
  state,
  label = NULL,
  size = 14/96,
  palette = NULL,
  style = NULL,
  gap = 7/96,
  align = c("left", "center", "right"),
  nudge_y = 1.5/96
)
```

## Arguments

- state:

  \`"yes"\`, \`"no"\`, \`"unknown"\`, or a logical.

- label:

  Optional text printed after the icon.

- size:

  Icon diameter (\`grid::unit\` or inches). Default 14px.

- palette:

  Named colours for yes/no/unknown; defaults to the theme's.

- style:

  Text style of the label (\[text_style()\] or a role name); defaults to
  the \`status_label\` role.

- gap:

  Space between icon and label.

- align:

  Horizontal position in its slot: \`"left"\`, \`"center"\`,
  \`"right"\`. Inside \[bb_table()\] the column alignment places it
  instead.

- nudge_y:

  Upward shift (inches) that lines the icon up optically with
  neighbouring text (text boxes sit slightly high). Default 1.5px.

## Value

A block.

## Examples

``` r
bb_status("yes", label = "Yes")
#> <bb_status>
bb_status(NA)
#> <bb_status>
```
