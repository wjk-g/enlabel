#' Attach labels to variable names
#'
#' @param df A df to be labelled.
#' @param labels A character vector containing variable labels.
#' @export
label_variables <- function(df, labels) {

  for (i in 1:ncol(df)) {
    expss::var_lab(df[[i]]) <- labels[i]
  }

  return(df)

}
