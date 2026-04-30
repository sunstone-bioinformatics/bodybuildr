# Two-column banner with logo and text

Builds a banner with a fixed-width image lane and title/subtitle text.

## Usage

``` r
str_banner_row(
  image_path,
  title = "Project Title",
  subtitle = "Concise one-liner about the project",
  layout_style = banner_layout_style(),
  text_style = NULL
)
```

## Arguments

- image_path:

  Path to a PNG/JPEG logo.

- title, subtitle:

  Text content.

- layout_style:

  A list from \[banner_layout_style()\] controlling geometry, colors,
  \`logo_position\` (\`"left"\`/\`"right"\`), and \`image_scale\`
  (\`"fit"\`/\`"fill"\`).

- text_style:

  A list with \`title\` and \`subtitle\` entries produced by
  \[text_style()\].

## Value

A \`gtable\` representing the banner.
