# Showcase: three very different documents

This vignette builds three documents with bodybuildr, each with its own
page size, typography and colour scheme. All the data is randomly
generated. The aim is to show the range of designs the same few building
blocks can produce, and how each piece of a page is put together.

| Document | Page | Look | Features on show |
|----|----|----|----|
| **HALCYON-7 telemetry** | 11 × 8.5 in landscape, 2 pages | Dark dashboard, gradient banner, monospaced accents | Custom blocks (KPI tiles, sparklines, meters), blocks inside table cells, rows that stretch to fill the page |
| **The Fermentation Almanac** | US Letter, 2 pages | Cream paper, serif type, newspaper masthead | Editorial typography, inline text styling, a masonry layout, tables from data frames, a header that changes by page |
| **Nightjar festival passes** | 4 × 6 in, 3 pages | A different gradient for each attendee | A small page size, headers built from page data, images made from arrays |

Every page shown here is exported by
[`export_pdf()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/export_pdf.md)
and then turned into a picture so it can be displayed. Unless the code
says otherwise, no height on any page is typed by hand: every block
measures itself.

If you’re new to bodybuildr, read
[`vignette("learn-bodybuildr")`](https://sunstone-bioinformatics.github.io/bodybuildr/articles/learn-bodybuildr.md)
first. It introduces each function step by step.

## Setup

``` r

library(bodybuildr)
library(grid)      # for drawing the custom blocks
library(ggplot2)   # for the charts
set.seed(7)        # makes the random data the same every time

out_dir <- file.path(tempdir(), "bodybuildr-showcase")
dir.create(out_dir, showWarnings = FALSE)

# Pick the first font from a wish list that is installed on this computer.
# If none of them are, fall back to one of R's generic families
# ("sans", "serif" or "mono"), which always work.
font_or <- function(wanted, fallback) {
  installed <- unique(systemfonts::system_fonts()$family)
  found <- wanted[wanted %in% installed]
  if (length(found) > 0) found[1] else fallback
}

# Export a page or document to PDF. While this vignette is being built, also
# turn every page into a PNG so it can be shown here. When you run the code
# yourself, it just tells you where the PDF is.
show_pdf <- function(doc, name, dpi = 110) {
  file <- export_pdf(doc, file.path(out_dir, paste0(name, ".pdf")))
  if (!has_pdftools || !isTRUE(getOption("knitr.in.progress"))) {
    return(message("Written to ", file))
  }
  n_pages <- pdftools::pdf_info(file)$pages
  pngs <- vapply(seq_len(n_pages), function(i) knitr::fig_path(".png", number = i), character(1))
  dir.create(dirname(pngs[1]), recursive = TRUE, showWarnings = FALSE)
  pdftools::pdf_convert(file, dpi = dpi, filenames = pngs, verbose = FALSE)
  knitr::include_graphics(pngs)
}
```

## Three custom blocks

Most of these pages use built-in blocks, but a dashboard needs a few
pieces of its own: a KPI tile with a sparkline, a progress meter and a
thin horizontal line.

You make a custom block with
[`new_block()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/new_block.md)
by giving it two functions:

- `measure(width)`: how tall the block is when it is given this width,
  in inches.
- `render(width, height)`: the drawing itself, as a grid grob, made for
  a box of exactly this size.

After that, the custom block works like any built-in one. It can sit in
stacks, columns, boxes and table cells, and it follows the page’s theme.

``` r

# How tall is one line of text in a given style? bodybuildr works in inches:
# the font size is in points and there are 72 points in an inch.
line_in <- function(style, role = "body") {
  gp <- text_gpar(style, role)
  gp$fontsize * gp$lineheight / 72
}

# Look up a colour by its theme name (such as "accent"). If the name isn't
# in the theme, assume it is already a normal colour (such as "#FF0000").
theme_col <- function(x) bb_get_theme()$colors[[x]] %||% x

# --- Block 1: a thin horizontal line ------------------------------------------
# Its height is the line's thickness (line widths are measured in 1/96 in).
hrule <- function(color = "ink", lwd = 1, lty = "solid") {
  new_block("hrule",
    measure = function(width) lwd / 96,
    render = function(width, height) {
      segmentsGrob(x0 = 0, y0 = 0.5, x1 = 1, y1 = 0.5,
                   gp = gpar(col = theme_col(color), lwd = lwd, lty = lty, lineend = "butt"))
    })
}

# --- Block 2: a KPI tile ------------------------------------------------------
# Layout, top to bottom:
#   LABEL                 ▲ 1.9%
#   4.82 AU
#   ~~~~~ sparkline ~~~~~
# Its height is worked out from the text styles, so a theme with bigger text
# makes taller tiles without any other change.
kpi_tile <- function(label, value, delta, series, good = "up") {
  label_style <- text_style("small", weight = 700)
  value_style <- text_style(size = 22, weight = 700)
  delta_style <- text_style("small", weight = 700)
  spark_height <- 0.32   # inches reserved for the sparkline
  spacing <- 0.05        # inches between the three rows

  new_block("kpi",
    measure = function(width) {
      line_in(label_style) + spacing + line_in(value_style) + spacing + spark_height
    },
    render = function(width, height) {
      theme <- bb_get_theme()

      # Is this change good news? Green if so, red if not.
      went_up <- delta >= 0
      is_good <- if (good == "up") went_up else !went_up
      delta_gp <- text_gpar(delta_style)
      delta_gp$col <- theme$status[[if (is_good) "yes" else "no"]]

      # grid measures y from the bottom; this turns "inches from the top"
      # into a grid position.
      from_top <- function(inches) unit(1, "npc") - unit(inches, "in")
      value_baseline <- line_in(label_style) + spacing + line_in(value_style)

      # Scale the series to 0-1 in both directions for the sparkline.
      xs <- (seq_along(series) - 1) / (length(series) - 1)
      ys <- (series - min(series)) / max(diff(range(series)), 1e-9)
      spark_area <- viewport(y = 0, height = unit(spark_height, "in"), just = "bottom")

      gTree(children = gList(
        # The label, in capitals (text_gpar() supplies font, size and colour;
        # the letter case is applied here).
        textGrob(toupper(label), x = 0, y = from_top(0), just = c("left", "top"),
                 gp = text_gpar(label_style)),
        # The change, top right, with an up or down arrow.
        textGrob(sprintf("%s%.1f%%", if (went_up) "▲ " else "▼ ", abs(delta)),
                 x = unit(1, "npc"), y = from_top(0), just = c("right", "top"), gp = delta_gp),
        # The big number.
        textGrob(value, x = 0, y = from_top(value_baseline), just = c("left", "bottom"),
                 gp = text_gpar(value_style)),
        # The sparkline: a faint filled area, the line, and a dot on the latest value.
        gTree(vp = spark_area, children = gList(
          polygonGrob(c(xs, 1, 0), c(ys, 0, 0),
                      gp = gpar(fill = adjustcolor(theme$colors$primary, 0.15), col = NA)),
          linesGrob(xs, ys, gp = gpar(col = theme$colors$primary, lwd = 1.4)),
          pointsGrob(1, ys[length(ys)], pch = 19, size = unit(3, "pt"),
                     gp = gpar(col = theme$colors$accent))))
      ))
    })
}

# --- Block 3: a progress meter ------------------------------------------------
# A rounded grey track with a coloured part filled in. Small enough for a
# table cell.
meter <- function(fraction, color = "primary", height = 0.08) {
  fraction <- max(0, min(1, fraction))   # keep it between 0% and 100%
  new_block("meter",
    measure = function(width) height,
    render = function(width, height) gTree(children = gList(
      roundrectGrob(r = unit(height / 2, "in"),
                    gp = gpar(fill = theme_col("rule_light"), col = NA)),
      roundrectGrob(x = 0, width = unit(fraction, "npc"), just = "left", r = unit(height / 2, "in"),
                    gp = gpar(fill = theme_col(color), col = NA)))))
}

# A custom block measures itself like any other:
measure_block(kpi_tile("Test", "42", 1, 1:5), width = 2)
#> [1] 0.988055555555556inches
```

## 1. HALCYON-7: a dark, landscape operations dashboard

A weekly briefing for an imaginary deep-space probe: KPI tiles across
the top, a trajectory chart beside a subsystem table, and a heatmap
beside an anomaly log. Page two has an instrument roster and notes.

### Theme

The theme sets the whole colour scheme. Built-in blocks such as section
headers, tables and legends draw with named colours (`panel`,
`rule_strong`, `on_primary`, …). Giving those names dark values here
turns all of them dark at once. The theme also adds a new colour
(`void`, the page background) and a new text role (`mono`, for
timestamps and numbers).

``` r

sans <- font_or(c("Avenir Next", "Helvetica Neue", "Helvetica"), "sans")
mono <- font_or(c("Menlo", "Courier New"), "mono")

ops_theme <- bb_theme(
  font = sans,
  base_size = 8.5,
  colors = list(
    void = "#0B0F1A",                                    # page background (a new name)
    panel = "#141B2D", panel_alt = "#1A2236",            # card backgrounds
    ink = "#E6EAF2", text2 = "#B8C0D2",                  # light text on dark
    muted = "#8892A6", faint = "#5C677D",
    primary = "#7AE7C7", accent = "#FF5D8F",             # mint and pink highlights
    on_primary = "#FFFFFF", on_primary_muted = "#D9CCF5",
    rule_strong = "#2E3A55", rule_light = "#232C42", rule_faint = "#1C2438"
  ),
  text = list(
    section = text_style(size = 10, weight = 700, color = "primary", case = "upper"),
    table_header = text_style(color = "void", weight = 700, case = "upper"),
    footer = text_style(family = mono, size = 7, color = "faint"),
    mono = text_style(family = mono, size = 7.5, color = "text2")   # a new role
  ),
  status = c(yes = "#3DDC97", no = "#FF4D6D", unknown = "#5C677D")
)
```

### Page template

The template is shared by both pages. It holds the page size, the
margins, the banner header and the footer.

The banner logo isn’t an image file. It’s a ringed planet drawn pixel by
pixel into a numeric array (height × width × 4 channels: red, green,
blue and transparency), which
[`bb_banner()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_banner.md)
accepts as it is.

``` r

planet <- local({
  n <- 240                                              # 240 x 240 pixels
  grid_xy <- expand.grid(x = seq(-1, 1, length.out = n), y = seq(-1, 1, length.out = n))
  x <- grid_xy$x; y <- grid_xy$y
  dist <- sqrt(x^2 + y^2)                               # distance from the centre

  # Light the sphere from the top left.
  shade <- pmin(1, pmax(0, 0.35 + 0.65 * (1 - sqrt((x + 0.45)^2 + (y - 0.45)^2) / 1.6)))

  # A tilted ellipse for the ring, hidden where it passes behind the planet.
  u <- x * cos(0.4) + y * sin(0.4)
  v <- -x * sin(0.4) + y * cos(0.4)
  ring_dist <- sqrt(u^2 + (v / 0.28)^2)
  ring <- ring_dist > 0.78 & ring_dist < 0.98 & !(dist <= 0.62 & v > 0)

  img <- array(0, c(n, n, 4))
  img[, , 1] <- matrix(0.48 * shade + 0.5 * ring, n)    # red
  img[, , 2] <- matrix(0.91 * shade, n)                 # green
  img[, , 3] <- matrix(0.78 * shade + 0.3 * ring, n)    # blue
  img[, , 4] <- matrix(as.numeric(dist <= 0.62 | ring), n)  # visible only on planet + ring
  pmin(img, 1)
})

ops_tpl <- page_template(
  width = 11, height = 8.5,                             # landscape
  margin_x = 0.45, margin_top = 0.35, margin_bottom = 0.3,
  theme = ops_theme,
  background = "void",                                  # a theme colour name works here too
  header_gap = 0.22, footer_gap = 0.15,
  header = bb_banner(
    "HALCYON-7  //  WEEKLY TELEMETRY",
    "Deep-space probe operations brief (fictional data)",
    logo = planet,
    style = banner_style(
      fill = gradient_fill(c("#121735", "#3A1C71", "#D76D77")),   # navy -> purple -> coral
      height = 0.95, logo_height = 0.62,
      accent_color = "primary", accent_height = 0.03,             # thin mint line under the band
      title_style = text_style("title", size = 20, family = mono))),
  # {sol} and {pass} come from each page's `data`; {page} and {pages} are automatic.
  footer = bb_page_footer("MISSION ELAPSED SOL {sol}  ·  DSN PASS {pass}", "PAGE {page}/{pages}",
                          style = footer_line_style(rule = line_style("rule_strong", 1)))
)

# Section headers with a short horizontal "pill" as the marker.
sec <- function(title, refs = NULL) {
  bb_section_header(title, refs = refs, style = section_header_style(
    marker_color = "accent", marker_width = 0.12, marker_height = 0.04,
    rule = line_style("rule_strong", 0.75)))
}

# A rounded dark card around any block.
panel <- function(x) bb_box(x, box_style(fill = "panel", radius = 0.06, padding = 0.14))
```

### Building the pieces

``` r

# --- KPI row: five cards side by side, equal widths --------------------------
random_walk <- function(n, start, step) start + cumsum(rnorm(n, 0, step))

kpis <- bb_cols(
  panel(kpi_tile("Distance from Sun", "4.82 AU", 1.9, random_walk(30, 4.6, 0.01))),
  panel(kpi_tile("Downlink rate", "11.4 kbps", -6.2, random_walk(30, 12, 0.4))),
  panel(kpi_tile("Battery SoC", "87%", 2.4, random_walk(30, 84, 0.6))),
  panel(kpi_tile("Hull temperature", "-142 °C", 3.1, random_walk(30, -145, 0.5), good = "down")),
  panel(kpi_tile("Science frames", "2,318", 14.0, cumsum(rpois(30, 75)))),
  gap = 0.14
)

# --- A dark ggplot theme to match the page -----------------------------------
# ggplot charts keep their own styling, so the colours and font are set here.
dark_gg <- theme_minimal(base_family = sans, base_size = 8) + theme(
  plot.background = element_rect(fill = "#141B2D", colour = NA),
  panel.grid = element_line(colour = "#232C42", linewidth = 0.3),
  text = element_text(colour = "#B8C0D2"),
  axis.text = element_text(colour = "#8892A6"),
  legend.position = "bottom",
  plot.margin = margin(8, 10, 6, 6),
  plot.title = element_text(colour = "#E6EAF2", face = "bold", size = 9))

# --- Trajectory chart: a spiral path out from the Sun ------------------------
t <- seq(0, 5.2 * pi, length.out = 400)
trajectory <- data.frame(
  x = (0.3 + t / 6) * cos(t),
  y = (0.3 + t / 6) * sin(t),
  phase = cut(t, 4, labels = c("Launch", "Cruise", "Flyby", "Science")))
bodies <- data.frame(x = c(0, 1.1, -2.2, 3.2), y = c(0, 0.4, -1.4, 0.9),
                     name = c("Sun", "Earth", "Mars", "Jupiter"), size = c(5, 2, 1.6, 3.5))

traj_plot <- ggplot(trajectory, aes(x, y)) +
  geom_path(aes(colour = phase), linewidth = 0.9, lineend = "round") +
  geom_point(data = bodies, aes(size = size), colour = "#E6EAF2", show.legend = FALSE) +
  geom_text(data = bodies, aes(label = name), colour = "#8892A6", vjust = -1.2, size = 2.4,
            family = sans) +
  annotate("point", x = tail(trajectory$x, 1), y = tail(trajectory$y, 1),   # the probe, now
           colour = "#FF5D8F", size = 3) +
  scale_colour_manual(values = c("#5C677D", "#7AE7C7", "#D76D77", "#FFD166"), name = NULL) +
  scale_size_identity() +
  coord_equal() +
  labs(title = "Heliocentric trajectory", x = NULL, y = NULL) +
  dark_gg

# --- Subsystem table ----------------------------------------------------------
# Each row mixes four kinds of cell: plain text, a status icon, a custom
# meter block and a styled cell().
subsystems <- data.frame(
  name = c("Power (RTG)", "Attitude control", "High-gain antenna", "Thermal",
           "Propulsion", "Star tracker B"),
  state = c("yes", "yes", "no", "yes", NA, "yes"),   # NA = no telemetry
  load = runif(6, 0.25, 0.95))

subsystem_rows <- lapply(seq_len(nrow(subsystems)), function(i) {
  load <- subsystems$load[i]
  list(
    subsystems$name[i],
    bb_status(subsystems$state[i], size = 0.12),
    meter(load, color = if (load > 0.85) "accent" else "primary"),   # pink when nearly full
    cell(sprintf("%d%%", round(100 * load)), style = "mono")
  )
})

sub_tbl <- bb_table(
  subsystem_rows,
  header = c("Subsystem", "OK", "Load", ""),
  # The name column takes whatever space is left; the other three are fixed.
  widths = unit(c(1, 0.35, 1.1, 0.4), c("null", "in", "in", "in")),
  align = c("left", "center", "left", "right"),
  style = table_style_grid(
    fill = "panel", alt_fill = "panel_alt", header_fill = "primary",
    border = line_style("rule_strong", 0.5), divider = line_style("rule_strong", 0.5),
    pad_x = 0.06, pad_y = 0.055))

status_legend <- bb_legend(list(
  legend_key("status", "Nominal", state = "yes"),
  legend_key("status", "Fault", state = "no"),
  legend_key("status", "No telemetry", state = "unknown"),
  legend_key("swatch", "Load > 85%", "accent")))

# --- Heatmap: instrument activity by hour and day -----------------------------
days <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
activity <- expand.grid(hour = 0:23, day = factor(days, levels = rev(days)))
activity$frames <- rpois(nrow(activity), lambda = 6 + 10 * exp(-((activity$hour - 14)^2) / 18))

heat <- ggplot(activity, aes(hour, day, fill = frames)) +
  geom_tile(colour = "#141B2D", linewidth = 0.6) +
  scale_fill_gradient(low = "#1A2236", high = "#7AE7C7", name = "frames / h") +
  scale_x_continuous(breaks = seq(0, 21, 3), expand = c(0, 0)) +
  labs(title = "Instrument duty cycle", x = "UTC hour", y = NULL) +
  dark_gg +
  theme(legend.key.height = unit(5, "pt"), legend.key.width = unit(28, "pt"),
        panel.grid = element_blank())

# --- Anomaly log: a coloured severity dot, a timestamp and a message ----------
anomalies <- data.frame(
  time = sprintf("SOL %d %02d:%02d", 1420 + sort(sample(0:3, 5, TRUE)),
                 sample(0:23, 5), sample(0:59, 5)),
  severity = c("accent", "#FFD166", "primary", "accent", "#FFD166"),
  message = c("HGA pointing error 0.42° > limit; safed to LGA",
              "Star tracker B stray light, 3 frames dropped",
              "Reaction wheel 2 momentum dump (planned)",
              "Bus undervoltage transient 27.1 V for 40 ms",
              "Thermal margin on IR detector < 2 K"))

anom_tbl <- bb_table(
  lapply(seq_len(nrow(anomalies)), function(i) list(
    bb_dot(anomalies$severity[i], size = 0.09),
    cell(anomalies$time[i], style = "mono"),
    anomalies$message[i])),
  widths = unit(c(0.18, 1.3, 1), c("in", "in", "null")),
  align = c("center", "left", "left"),
  style = table_style(divider = line_style("rule_strong", 0.5), pad_y = 0.05, valign = "top"))
```

### Page 1: rows that fill the page

The page is three rows: the KPI tiles, then two rows that each pair a
chart with a table.

A chart without a fixed height is **flexible**. It stretches to match
the tallest block next to it, so each chart is exactly as tall as the
table beside it.

The last row also absorbs any height left over on the page. The
[`bb_spacer()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_spacer.md)
at the bottom of its right-hand column has no height of its own. That
makes the column flexible, and with every block in the row now flexible,
the row grows to fill the page down to the footer. The heatmap grows
with it.

``` r

ops_page1 <- bb_page(
  kpis,

  # Row 2: trajectory chart | subsystem table + legend (the right column is 4.1 in wide)
  bb_cols(
    panel(bb_plot(traj_plot, min_height = 1.95)),
    bb_stack(sec("Subsystems", refs = "live"), sub_tbl, status_legend, gap = 0.08),
    widths = unit(c(1, 4.1), c("null", "in")), gap = 0.2),

  # Row 3: heatmap | anomaly log + legend, stretched to the bottom of the page
  bb_cols(
    panel(bb_plot(heat, min_height = 1.5)),
    bb_stack(
      sec("Anomaly log", refs = "72 h"),
      anom_tbl,
      bb_legend(list(legend_key("dot", "Critical", "accent"),
                     legend_key("dot", "Warning", "#FFD166"),
                     legend_key("dot", "Info", "primary"))),
      bb_spacer(),                           # this is what lets the row fill the page
      gap = c(0.06, 0.06, 0)),
    widths = unit(c(1, 4.1), c("null", "in")), gap = 0.2),

  template = ops_tpl,
  gap = 0.18,
  data = list(sol = 1423, pass = "DSS-43")   # fills {sol} and {pass} in the footer
)
```

### Page 2: lined-up tables, a placeholder and a note

The instrument table has two-line rows (name plus team), while the plan
table next to it has one-line rows. `sync_rows = TRUE` makes both tables
use the same row heights, so their dividers line up across the page.

``` r

instruments <- data.frame(
  code = c("IRS", "MAG", "UVS", "PLS", "CAM-N", "CAM-W", "RSS", "DUST"),
  name = c("Infrared spectrometer", "Magnetometer", "UV spectrograph", "Plasma analyser",
           "Narrow-angle camera", "Wide-angle camera", "Radio science", "Dust counter"),
  team = c("JPL / Pasadena", "IC / London", "LASP / Boulder", "SwRI / San Antonio",
           "MSSS / San Diego", "MSSS / San Diego", "DLR / Cologne", "MPI / Heidelberg"),
  gb = round(rexp(8, 1 / 40), 1))

# Data volume as five dots: one filled dot per 20 GB, the rest grey.
volume_dots <- function(gb) {
  filled <- min(5, ceiling(gb / 20))
  bb_dot(c(rep("primary", filled), rep("rule_strong", 5 - filled)), size = 0.07, gap = 0.025)
}

inst_tbl <- bb_table(
  lapply(seq_len(nrow(instruments)), function(i) list(
    cell(instruments$code[i], style = text_style(family = mono, weight = 700, color = "primary")),
    # "\n" starts a second line; span() makes it smaller and muted.
    paste0(instruments$name[i], "\n", span(instruments$team[i], color = "muted", size = 7)),
    volume_dots(instruments$gb[i]),
    cell(sprintf("%.1f GB", instruments$gb[i]), style = "mono"))),
  header = c("ID", "Instrument", "Volume", ""),
  header_case = "upper",
  widths = unit(c(0.6, 1, 0.6, 0.6), c("in", "null", "in", "in")),
  align = c("left", "left", "left", "right"),
  style = table_style(divider = line_style("rule_strong", 0.5), header_rule = line_style("primary", 1)))

# Uplink approval for each instrument, with a label that matches its icon.
uplink <- sample(c("yes", "yes", "yes", "no", NA), nrow(instruments), replace = TRUE)
uplink_label <- function(state) {
  if (is.na(state)) "Pending" else if (state == "yes") "Approved" else "Rejected"
}

plan_tbl <- bb_table(
  lapply(seq_len(nrow(instruments)), function(i) list(
    sample(c("Survey", "Calibrate", "Stare", "Idle", "Raster scan"), 1),
    bb_status(uplink[i], label = uplink_label(uplink[i]), size = 0.1))),
  header = c("Next week", "Uplink"),
  header_case = "upper",
  style = table_style(divider = line_style("rule_strong", 0.5), header_rule = line_style("primary", 1)))

ops_page2 <- bb_page(
  sec("Instrument roster & next uplink"),
  bb_cols(inst_tbl, plan_tbl, widths = c(2.4, 1), gap = 0.3, sync_rows = TRUE),

  bb_cols(
    # A striped panel for data that hasn't arrived yet. It is flexible, so it
    # matches the height of the note beside it.
    bb_placeholder("Spectrometer cube downlink scheduled for SOL 1426. Nothing to show yet.",
                   fill = stripe_fill(c("panel", "panel_alt"), angle = 30, width = 0.12),
                   label_fill = "void", style = text_style("placeholder", color = "muted")),
    panel(bb_stack(
      bb_text("Flight director note", style = text_style("subheading", color = "accent")),
      bb_text(paste0("The **HGA fault** on SOL 1421 cost one DSN pass. ",
                     "Mitigation: re-point with star tracker A only, accept **0.1°** extra jitter.\n\n",
                     "- Raise IR detector heater set-point by 1.5 K\n",
                     "- Defer dust counter calibration\n",
                     "- Request extra 70 m pass"),
              markup = "markdown", style = "note"),
      gap = 0.06)),
    widths = c(1, 1), gap = 0.2),

  template = ops_tpl,
  gap = c(0.06, 0.25),
  data = list(sol = 1423, pass = "DSS-43")
)
```

![The two pages of the HALCYON-7 dark telemetry
dashboard.](showcase_files/figure-html/ops-show-1.png)![The two pages of
the HALCYON-7 dark telemetry
dashboard.](showcase_files/figure-html/ops-show-2.png)

## 2. The Fermentation Almanac: a serif magazine

The opposite mood: warm paper, a classic serif typeface, italic section
heads and a newspaper-style masthead. There is no banner. The masthead
is a stack of thin and thick lines (the `hrule()` block from above)
around centred text.

### Theme and template

``` r

serif <- font_or(c("Georgia", "PT Serif", "Times New Roman"), "serif")

alm_theme <- bb_theme(
  font = serif,
  base_size = 9.5,
  colors = list(
    paper = "#F6F0E4",                                  # page background (a new name)
    ink = "#2B2118", text2 = "#4A3B2C", muted = "#7C6A55", faint = "#A8977F",
    primary = "#7A2E1F",                                # oxblood
    accent = "#C8963E",                                 # mustard
    panel = "#EDE3CF", panel_alt = "#E4D7BE",
    rule_strong = "#2B2118", rule_light = "#CDBF9F", rule_faint = "#DDD2BA"
  ),
  text = list(
    body = text_style(lineheight = 1.5),                # airy body text
    section = text_style(size = 13, weight = 400, italic = TRUE, color = "primary"),
    kicker = text_style(size = 7.5, weight = 700, color = "accent", case = "upper"),  # new role
    quote = text_style(size = 15, italic = TRUE, color = "primary", lineheight = 1.3), # new role
    table_header = text_style(size = 7.5, weight = 700, color = "ink"),
    footer = text_style(size = 7.5, italic = TRUE, color = "muted")
  ),
  status = c(yes = "#5C7A3A", no = "#7A2E1F", unknown = "#A8977F")
)

# Section heads: italic title over a thin line, no marker.
alm_sec <- function(title, refs = NULL) {
  bb_section_header(title, refs = refs, style = section_header_style(
    marker_color = NA, rule = line_style("rule_light", 0.75), space_below = 0.06))
}

# The header is a function of the page: nothing on page 1 (the masthead is
# there), a running header on every later page.
alm_tpl <- page_template(
  margin_x = 0.7, margin_top = 0.55, margin_bottom = 0.5,
  theme = alm_theme,
  background = "paper",
  header = function(ctx) {
    if (ctx$page == 1) return(NULL)
    bb_running_header("The Fermentation Almanac", "Vol. III · No. 9",
                      style = header_line_style(
                        left_style = text_style(italic = TRUE, color = "ink", weight = 400),
                        rule = line_style("ink", 0.6)))
  },
  footer = bb_page_footer("Printed on paper that was once a tree", "— {page} —",
                          style = footer_line_style(rule = NULL)),
  header_gap = 0.25)
```

### Page 1: masthead, two columns of articles, a chart and a recipe

``` r

# Placeholder text made from fermentation words.
lorem <- function(n_words) {
  words <- c("brine", "lactic", "crock", "salt", "cabbage", "weight", "bubbles", "cellar",
             "patience", "sour", "garlic", "dill", "kahm", "yeast", "starter", "jar", "rind",
             "koji", "miso", "whey", "temperature", "the", "of", "and", "a", "slowly", "every",
             "morning", "under", "with", "until")
  s <- paste(sample(words, n_words, replace = TRUE), collapse = " ")
  paste0(toupper(substr(s, 1, 1)), substr(s, 2, nchar(s)), ".")
}
para <- function(n_sentences) paste(replicate(n_sentences, lorem(sample(9:16, 1))), collapse = " ")

# --- Masthead: thick and thin lines around the title and a strapline --------
masthead <- bb_stack(
  hrule("ink", 2.5), bb_spacer(0.03), hrule("ink", 0.6),
  bb_text("The Fermentation Almanac", align = "center",
          style = text_style(size = 38, weight = 700, lineheight = 1.1)),
  bb_cols(
    bb_text("Vol. III · No. 9", style = "kicker"),
    bb_text("Autumn, being the season of crocks & brine", align = "center",
            style = text_style("note", italic = TRUE)),
    bb_text("Price: one sourdough starter", align = "right", style = "kicker"),
    widths = c(1, 2, 1), valign = "center"),
  hrule("ink", 0.6), bb_spacer(0.03), hrule("ink", 2.5),
  gap = 0.06)

# --- Pull quote with a mustard bar on its left -------------------------------
# The bar is a filled box around an empty flexible spacer. It has no height
# of its own, so it stretches to exactly the height of the quote.
pull_quote <- bb_cols(
  bb_box(bb_spacer(), box_style(fill = "accent")),
  bb_stack(
    bb_text("“Salt is a clock. Two percent tells time in weeks; five percent, in seasons.”",
            style = "quote"),
    bb_text("— Old cellar proverb, probably invented", style = text_style("small", italic = TRUE)),
    gap = 0.06),
  widths = unit(c(0.05, 1), c("in", "null")), gap = 0.14)

# --- Chart: pH falling over three weeks for three ferments -------------------
ph <- do.call(rbind, lapply(c("Sauerkraut", "Kimchi", "Dill pickles"), function(batch) {
  day <- 0:21
  rate <- runif(1, 0.15, 0.35)
  data.frame(day = day, ph = 3.3 + 3 * exp(-rate * day) + rnorm(22, 0, 0.04), batch = batch)
}))

ph_plot <- ggplot(ph, aes(day, ph, linetype = batch, colour = batch)) +
  geom_hline(yintercept = 4.6, colour = "#7A2E1F", linewidth = 0.3, linetype = "dotted") +
  geom_line(linewidth = 0.6) +
  annotate("text", x = 21, y = 4.7, label = "safe below 4.6", hjust = 1, family = serif,
           size = 2.6, colour = "#7A2E1F", fontface = "italic") +
  scale_colour_manual(values = c("#2B2118", "#C8963E", "#7A2E1F")) +
  scale_linetype_manual(values = c("solid", "longdash", "dotdash")) +
  labs(x = "Day", y = "pH") +
  theme_classic(base_family = serif, base_size = 8) +
  theme(legend.position = "none",                       # bodybuildr draws the legend instead
        plot.background = element_rect(fill = "#F6F0E4", colour = NA),
        panel.background = element_rect(fill = "#F6F0E4", colour = NA))

ph_legend <- bb_legend(
  list(legend_key("line", "Sauerkraut", "#2B2118"),
       legend_key("dash", "Kimchi", "#C8963E"),
       legend_key("line", "Dill pickles", "#7A2E1F")),
  note = "n = 1 crock each")

# --- Recipe card --------------------------------------------------------------
# cell() styles single cells: an indented italic sub-row, a faint "to taste",
# a Markdown "Total" and a bold total weight.
recipe <- bb_table(
  list(
    list("Green cabbage", "1.0 kg", "100%"),
    list(cell("cored, shredded fine", style = text_style("small", italic = TRUE), indent = 0.15), "", ""),
    list("Sea salt (no iodine)", "20 g", "2%"),
    list("Caraway seed", "4 g", "0.4%"),
    list("Juniper berries", "6", cell("to taste", style = text_style(color = "faint", italic = TRUE))),
    list(cell("**Total**", markup = "markdown"), cell("1.03 kg", style = text_style(weight = 700)), "")),
  header = c("Ingredient", "Qty", "Baker's %"),
  header_case = "upper",
  widths = c(2.4, 1, 1.3),
  align = c("left", "right", "right"),
  style = table_style(header_rule = line_style("ink", 1.2), divider = line_style("rule_light", 0.5),
                      pad_y = 0.045))

# --- Suitability checklist: status icons and diamond "difficulty" marks -------
suitability <- bb_table(
  list(list("Vegan", bb_status("yes", size = 0.11)),
       list("Gluten-free", bb_status("yes", size = 0.11)),
       list("Low sodium", bb_status("no", size = 0.11)),
       list("Kid-approved", bb_status(NA, size = 0.11)),
       list("Difficulty", bb_dot(c("primary", "primary", "rule_light"), shape = "diamond", size = 0.1))),
  widths = c(2, 1),
  align = c("left", "right"),
  style = table_style(divider = line_style("rule_light", 0.5), pad_y = 0.04, last_divider = FALSE))

# --- Putting page 1 together --------------------------------------------------
feature <- bb_stack(
  bb_text("Feature", style = "kicker"),
  bb_text("Two percent, forever", style = text_style(size = 22, weight = 700, lineheight = 1.1)),
  bb_text(para(4)),
  pull_quote,
  bb_text(para(3)),
  gap = 0.1)

letters_column <- bb_stack(
  bb_text("Dispatch", style = "kicker"),
  bb_text("Letters from the cellar", style = text_style(size = 15, weight = 700, lineheight = 1.15)),
  # span() colours the "Q." and "A." without breaking the sentence apart.
  bb_text(paste0(span("Q. ", weight = 700, color = "primary"), lorem(14), "\n",
                 span("A. ", weight = 700, color = "accent"), para(2))),
  bb_text(paste0(span("Q. ", weight = 700, color = "primary"), lorem(10), "\n",
                 span("A. ", weight = 700, color = "accent"), para(1))),
  bb_box(bb_text(paste0("Write to us: ", link("https://example.org/almanac", "example.org/almanac")),
                 style = "note", link_color = "primary"),
         box_style(border = line_style("ink", 0.6, lty = "22"), padding = 0.08)),   # dashed coupon
  gap = 0.1)

alm_page1 <- bb_page(
  masthead,
  bb_cols(feature, letters_column, widths = c(1.6, 1), gap = 0.3),
  alm_sec("The acid curve", refs = "fig. 1"),
  bb_cols(
    bb_stack(bb_plot(ph_plot, height = 1.9), ph_legend, gap = 0.02),
    bb_stack(bb_text("Recipe card", style = "kicker"), recipe, bb_spacer(0.08),
             bb_text("Suitability", style = "kicker"), suitability, gap = 0.05),
    widths = c(1.25, 1), gap = 0.3),
  template = alm_tpl,
  gap = c(0.25, 0.25, 0.04)
)
```

### Page 2: masonry classifieds

Twelve small ads of different lengths, in five box styles. They are
dealt into three columns, and each column is its own
[`bb_stack()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/bb_stack.md).
Because every ad is exactly as tall as its text, the columns pack
tightly like a masonry wall, with no grid of fixed cells.

``` r

ad_styles <- list(
  box_style(border = line_style("ink", 0.8), padding = 0.1),                  # outlined
  box_style(fill = "panel", padding = 0.1),                                   # shaded
  box_style(border = line_style("ink", 0.8, lty = "22"), padding = 0.1),      # dashed
  box_style(fill = "ink", padding = 0.1),                                     # inverted (dark)
  box_style(border = line_style("primary", 1.5), radius = 0.08, padding = 0.1))  # rounded

ad_titles <- c("Crocks wanted", "Starter seeks discard", "Lost: kombucha SCOBY", "Brine therapy",
               "Koji lessons", "Weights for hire", "Cellar to let", "Pickle swap",
               "Miso of the month", "Free whey", "Airlock repair", "Honest sauerkraut")

ads <- lapply(seq_along(ad_titles), function(i) {
  style <- ad_styles[[(i - 1) %% length(ad_styles) + 1]]   # cycle through the five styles
  dark <- identical(style$fill, "ink")                     # light text on the dark ad
  bb_box(bb_stack(
    bb_text(ad_titles[i], style = text_style(weight = 700, case = "upper", size = 8.5,
                                             color = if (dark) "paper" else "ink")),
    bb_text(lorem(sample(8:30, 1)), style = text_style("note", color = if (dark) "panel" else "text2")),
    gap = 0.04), style)
})

# Deal the ads into three columns: 1, 2, 3, 1, 2, 3, ...
column_of <- rep_len(1:3, length(ads))
masonry <- bb_cols(
  .list = lapply(1:3, function(k) bb_stack(.list = ads[column_of == k], gap = 0.12)),
  gap = 0.15)

almanac_table <- data.frame(
  Month = month.abb[9:12],
  `Cellar °C` = sprintf("%.1f", runif(4, 9, 16)),
  `Best for` = c("Cucumbers", "Cabbage & roots", "Miso, doenjang", "Citrus preserves"),
  Moon = c("Waxing", "Full", "Waning", "New"),
  check.names = FALSE)

alm_page2 <- bb_page(
  alm_sec("Classifieds"),
  masonry,
  bb_placeholder("Your advertisement here. Rates on request; payment accepted in jars.",
                 fill = stripe_fill(c("paper", "panel"), angle = 60, width = 0.06), height = 0.9,
                 style = text_style("placeholder", italic = TRUE), label_fill = "paper"),
  alm_sec("Almanac table"),
  # A data frame goes straight in; its column names become the header.
  bb_table(almanac_table,
           widths = c(1, 1, 2.5, 1),
           align = c("left", "right", "left", "left"),
           header_case = "upper",
           style = table_style_grid(header_fill = "ink", alt_fill = "panel", fill = "paper",
                                    header_style = text_style("table_header", color = "paper"),
                                    border = line_style("ink", 0.6),
                                    divider = line_style("rule_light", 0.5))),
  bb_spacer(),   # takes up the leftover space, pushing the colophon to the bottom
  bb_text("Colophon: every height on this page was measured, none typed.",
          align = "center", style = text_style("small", italic = TRUE)),
  template = alm_tpl,
  gap = c(0.04, 0.2, 0.25, 0.04, 0, 0)
)
```

![The two pages of The Fermentation Almanac
magazine.](showcase_files/figure-html/alm-show-1.png)![The two pages of
The Fermentation Almanac
magazine.](showcase_files/figure-html/alm-show-2.png)

## 3. Nightjar: 4 × 6 in festival passes

A lanyard pass for each attendee of an imaginary festival, one page per
person. Each pass has its own colours. Every page carries its colours in
its `data`, and the template’s header is a function that reads them and
builds the banner. The QR-style code is a random matrix of black and
white squares, scaled up into an image array.

``` r

display <- font_or(c("Futura", "Avenir Next", "Helvetica Neue"), "sans")

fest_theme <- bb_theme(
  font = display,
  base_size = 8,
  colors = list(ink = "#16112B", muted = "#6B6585", rule_light = "#E3DFF0",
                panel = "#F3F0FA", panel_alt = "#E6E0F5",
                on_primary = "#FFFFFF", on_primary_muted = "#FFFFFFCC"),
  text = list(title = text_style(size = 22, weight = 700, case = "upper"),
              subtitle = text_style(size = 9, case = "upper"),
              table_header = text_style(size = 6.5, weight = 700, color = "muted", case = "upper"),
              footer = text_style(size = 6.5, color = "muted")))

# A random "QR code": a 25 x 25 grid of squares with the three corner
# targets, each square scaled up to 10 x 10 pixels so it stays crisp.
qr <- function(seed, n = 25, scale = 10) {
  set.seed(seed)
  m <- matrix(rbinom(n * n, 1, 0.5), n)
  add_target <- function(m, row, col) {
    m[row:(row + 6), col:(col + 6)] <- 1               # outer square
    m[(row + 1):(row + 5), (col + 1):(col + 5)] <- 0   # white ring
    m[(row + 2):(row + 4), (col + 2):(col + 4)] <- 1   # inner square
    m
  }
  m <- add_target(add_target(add_target(m, 1, 1), 1, n - 6), n - 6, 1)
  pixels <- kronecker(1 - m, matrix(1, scale, scale))  # 1 = white, 0 = black
  array(rep(pixels, 3), c(dim(pixels), 3))             # same value in R, G and B = grey scale
}

passes <- data.frame(
  name = c("Ada Okonkwo", "Mateo Ríos-Villanueva", "Yuki Tanaka"),
  tier = c("Artist", "Weekend", "Crew"),
  colour_from = c("#FF6B6B", "#4D96FF", "#6BCB77"),
  colour_to = c("#845EC2", "#16112B", "#0F4C5C"),
  zones_allowed = c(3, 2, 4),
  serial = sprintf("NJ-%05d", c(90408, 28727, 51130)))

zones <- c(Main = "#FF6B6B", Forest = "#6BCB77", Lake = "#4D96FF", Backstage = "#16112B")

fest_tpl <- page_template(
  width = 4, height = 6,                               # a 4 x 6 in card
  margin_x = 0.25, margin_top = 0.2, margin_bottom = 0.18,
  theme = fest_theme,
  # Built separately for every page from that page's data:
  header = function(ctx) {
    bb_banner("Nightjar", paste(ctx$data$tier, "pass · 12–14 June"),
              style = banner_style(
                fill = gradient_fill(c(ctx$data$colour_from, ctx$data$colour_to), dir = "tlbr"),
                height = 1.0, divider = NULL, accent_color = NA))
  },
  footer = bb_page_footer("No. {serial}", "{page} of {pages}"),
  header_gap = 0.18, footer_gap = 0.1)

make_pass <- function(i) {
  p <- passes[i, ]
  allowed <- names(zones)[seq_len(p$zones_allowed)]

  access_table <- bb_table(
    list(list("Gate", c("Lake", "South", "North")[i]),
         list("Camping", bb_status(i != 2, size = 0.1)),        # TRUE/FALSE work as yes/no
         list("Lockers", bb_status(NA, size = 0.1)),            # NA shows as "unknown"
         list("Zones", bb_dot(zones[allowed], size = 0.1, shape = "square"))),
    header = c("Access", ""),
    widths = c(1, 1),
    align = c("left", "right"),
    style = table_style(pad_y = 0.04, divider = line_style("rule_light", 0.5)))

  tear_off <- bb_box(
    bb_cols(bb_text("Drink token ×3", style = text_style(weight = 700, case = "upper")),
            bb_text("tear here", align = "right", style = text_style("small", italic = TRUE)),
            valign = "center"),
    box_style(fill = stripe_fill(c("panel", "panel_alt"), angle = 135, width = 0.05),
              border = line_style("muted", 0.8, lty = "22"),   # dashed cut line
              padding = c(0.1, 0.12), radius = 0.06))

  bb_page(
    bb_text(p$name, style = text_style(size = 17, weight = 700, lineheight = 1.05)),
    bb_cols(bb_image(qr(i)), access_table, widths = c(1, 1.2), gap = 0.18, valign = "center"),
    bb_legend(Map(function(zone, colour) legend_key("swatch", zone, colour), names(zones), zones),
              key_size = 0.1, gap = 0.12),
    bb_spacer(),   # pushes the tear-off token down onto the footer
    tear_off,
    template = fest_tpl,
    gap = c(0.12, 0.12, 0, 0),
    data = list(serial = p$serial, tier = p$tier,
                colour_from = p$colour_from, colour_to = p$colour_to))
}

fest_pages <- lapply(seq_len(nrow(passes)), make_pass)
```

![Three Nightjar festival passes, one per
attendee.](showcase_files/figure-html/fest-show-1.png)![Three Nightjar
festival passes, one per
attendee.](showcase_files/figure-html/fest-show-2.png)![Three Nightjar
festival passes, one per
attendee.](showcase_files/figure-html/fest-show-3.png)

## What each document used

| Technique | Where it appears |
|----|----|
| Custom blocks with [`new_block()`](https://sunstone-bioinformatics.github.io/bodybuildr/reference/new_block.md) | KPI tiles, progress meters, masthead lines |
| Blocks inside table cells | Status icons, meters, dots and diamonds in every document |
| Flexible blocks filling space | Charts matching their tables, the dashboard’s last row, the pull-quote bar, the pushed-down colophon and tear-off token |
| Themes with new colours and roles | `void`, `paper`, `mono`, `kicker`, `quote` |
| Page-dependent headers | No header on the magazine cover; a different banner on each festival pass |
| Tokens in headers and footers | `{sol}`, `{pass}`, `{serial}`, `{page}`, `{pages}` |
| Side-by-side tables with matching rows | The instrument roster and uplink plan |
| Images from arrays | The planet logo and the QR codes |
| Fills | Gradient banners, striped placeholders and the striped tear-off |
| Any page size | 11 × 8.5 in, US Letter and 4 × 6 in |
