# Stack blocks vertically

Children are placed top to bottom, each as tall as it measures. Flexible
children (plots without a height, \[bb_spacer()\] without a height)
share the height left over when the stack is given more room than its
content needs, as the body of a \[bb_page()\] is. A stack with flexible
children is itself flexible.

## Usage

``` r
bb_stack(..., gap = 0, .list = NULL)
```

## Arguments

- ...:

  Blocks or anything \[as_block()\] accepts. \`NULL\`s are dropped.

- gap:

  Space between children (\`grid::unit\` or inches), recycled.

- .list:

  Optional list of further children.

## Value

A block.

## Examples

``` r
bb_stack("Title", "Body text", gap = unit(6, "pt"))
#> <bb_stack>
```
