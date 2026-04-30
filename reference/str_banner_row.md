# Two-column banner with logo and text

Builds a banner with a fixed-width image lane and title/subtitle text.

## Usage

``` r
str_banner_row(
  image_path,
  title = "Project Title",
  subtitle = "Concise one-liner about the project",
  layout_style = banner_layout_style(),
  text_style = NULL,
  image_scale = c("fit", "fill"),
  logo_position = c("left", "right")
)
```

## Arguments

- image_path:

  Path to a PNG/JPEG logo.

- title, subtitle:

  Text content.

- layout_style:

  A list from \[layout_style()\] or \[banner_layout_style()\]
  controlling geometry and colors.

- text_style:

  A list with \`title\` and \`subtitle\` entries produced by
  \[text_style()\].

- image_scale:

  How to place the logo: \`"fit"\` (preserve aspect ratio) or \`"fill"\`
  (fill the panel).

- logo_position:

  Which side the logo panel appears on: \`"left"\` or \`"right"\`.

## Value

A \`gtable\` representing the banner.
