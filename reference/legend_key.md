# Legend key

One entry of a \[bb_legend()\].

## Usage

``` r
legend_key(type, label, color = NULL, state = NULL)
```

## Arguments

- type:

  \`"swatch"\` (square), \`"dot"\`, \`"diamond"\`, \`"status"\` (a
  \[bb_status()\] icon), \`"line"\` or \`"dash"\`.

- label:

  Label text.

- color:

  Key colour (theme names allowed). Not needed for \`"status"\`.

- state:

  Status for \`type = "status"\`.

## Value

A \`bb_legend_key\` object.

## Examples

``` r
legend_key("swatch", "<80%", "#C8503F")
#> $type
#> [1] "swatch"
#> 
#> $label
#> [1] "<80%"
#> 
#> $color
#> [1] "#C8503F"
#> 
#> $state
#> NULL
#> 
#> attr(,"class")
#> [1] "bb_legend_key"
legend_key("status", "Meets", state = "yes")
#> $type
#> [1] "status"
#> 
#> $label
#> [1] "Meets"
#> 
#> $color
#> NULL
#> 
#> $state
#> [1] "yes"
#> 
#> attr(,"class")
#> [1] "bb_legend_key"
```
