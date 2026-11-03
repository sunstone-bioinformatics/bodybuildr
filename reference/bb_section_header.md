# Section header

A small accent marker, the section title, optional muted references such
as "\[1\]\[2\]", and a rule underneath. No filled band.

## Usage

``` r
bb_section_header(title, refs = NULL, style = section_header_style())
```

## Arguments

- title:

  Section title (one line).

- refs:

  Optional references printed after the title.

- style:

  A \[section_header_style()\].

## Value

A block.

## Examples

``` r
bb_section_header("Vaccination coverage", refs = "[3]")
#> <bb_section_header>
```
