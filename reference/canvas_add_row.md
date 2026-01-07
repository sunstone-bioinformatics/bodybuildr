# Append a row to a canvas

Adds a grob as a new row at the bottom of an existing canvas.

## Usage

``` r
canvas_add_row(canvas, grob, height)
```

## Arguments

- canvas:

  A \`gtable\` produced by \`new_canvas()\`.

- grob:

  A grob/gtable to insert as the next row.

- height:

  A non-negative \`grid::unit\` giving the row height.

## Value

The updated \`gtable\` with the new row added.
