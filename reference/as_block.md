# Turn content into a block

Every container calls \`as_block()\` on its children, so any of these
can be passed wherever a block is expected:

## Usage

``` r
as_block(x)
```

## Arguments

- x:

  Content.

## Value

A block, or \`NULL\`.

## Details

\| Input \| Block \| \|—\|—\| \| a block \| unchanged \| \| character,
number, factor \| \[bb_text()\] \| \| path to a \`.png\` / \`.jpg\` file
\| \[bb_image()\] \| \| numeric array, \`raster\`, \`nativeRaster\` \|
\[bb_image()\] \| \| ggplot \| \[bb_plot()\] (flexible height) \| \|
grob, gTree, gtable \| \[bb_grob()\] (flexible height) \| \| \`NULL\` \|
\`NULL\` (dropped by stacks, an empty slot in columns) \|

## Examples

``` r
as_block("Some text")
#> <bb_text>
```
