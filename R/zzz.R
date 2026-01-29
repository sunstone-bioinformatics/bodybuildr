# Package load hooks --------------------------------------------------------
#
# R convention: files named zzz*.R are loaded last. We keep .onLoad() here so
# S3 method registration happens after other definitions are available.
.onLoad <- function(libname, pkgname) {
  if (requireNamespace("grid", quietly = TRUE)) {
    base::registerS3method(
      "drawDetails",
      "bbdr_raster_grob",
      drawDetails.bbdr_raster_grob,
      envir = asNamespace("grid")
    )
    base::registerS3method(
      "makeContent",
      "bbdr_raster_grob",
      makeContent.bbdr_raster_grob,
      envir = asNamespace("grid")
    )
  }
}
