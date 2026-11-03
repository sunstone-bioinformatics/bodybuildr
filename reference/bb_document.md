# Document

An ordered set of pages exported to one PDF. \`NULL\` pages are dropped
before numbering, so an optional page (built only when there is data)
shifts the later page numbers and the total automatically.

## Usage

``` r
bb_document(..., .list = NULL)
```

## Arguments

- ...:

  \[bb_page()\]s or \`NULL\`s.

- .list:

  Optional list of further pages.

## Value

A \`bb_document\` object.

## Examples

``` r
doc <- bb_document(bb_page("One"), NULL, bb_page("Two"))
length(doc$pages)
#> [1] 2
```
