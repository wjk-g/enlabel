#' Extract question labels from LimeSurvey
#'
#' The function extracts variable descriptions directly from an SPSS file
#' (if a path is provided) or from a dataframe object with labels
#' attached (i.e. with a `$variable.labels` attribute).
#'
#' @param labelled_data A path to a .sav file or a labelled R dataframe.
#'
#' @export
extract_labels_from_data <- function(labelled_data) {

  # Due to issues with the haven package we are using
  # the foreign's package read.spss function for loading .sav files.
  if (is.character(labelled_data)) { # if labelled_data is a path to .sav file

    if (substr(labelled_data, nchar(labelled_data)-3, nchar(labelled_data)) != '.sav') {
      stop("You have not provided a path to a .sav file!")
    }
    spss_data <- foreign::read.spss(labelled_data, to.data.frame = TRUE)
  } else {
    spss_data <- labelled_data
  }

  codes_and_labels <- tibble::tibble(match = names(spss_data),
                                     labels = attributes(spss_data)$variable.labels)

  enlabel_cache$codes_and_labels <- codes_and_labels

  return(codes_and_labels)
}

if (!exists("enlabel_cache", mode="environment")) {
  enlabel_cache <- new.env(parent = emptyenv())
}
