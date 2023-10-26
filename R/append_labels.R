#' Append labels to a dataframe containing question codes
#'
#' Appends a column of human-readable labels to a dataframe containing. The labels have
#' to be first sourced using `extract_labels_from_ls` or `extract_labels_from_data`.
#'
#' @param df A dataframe to be labelled.
#' @param colname Name of the column with LimeSurvey question codes.
#' @param source A dataframe containing question labels.
#' @param trim If `TRUE`, `append_labels()` will attempt to include only the subquestion text
#' and discard the parent-question text.
#' @description
#' One of the most common operations when working with multiplechoice survey
#' data spread across a number of columns involves transforming the data
#' from wide to long format. Long format data, especially in the tidyverse context,
#' lends itself more easily to certain kinds of analyses and visualisations. However,
#' the output of these transformations usually comprises (only)
#' numbers and question codes and can be difficult to read, interpret, and communicate.
#' append_labels() aims to solve this problem by adding a new column to your data
#' with human-readable labels.
#'
#' For the function to work, the names of the variables in your dataframe
#' *have to match the question codes in your LimeSurvey survey*.
#'
#' @section Example:
#'
#' The example below presents a typical tasks when working with
#' survey data - selecting and summarising a group of variables sharing a
#' common prefix. The names of the pivoted variables (i.e. question codes) are
#' stored in the "name" column.
#'
#' Adding `append_labels()` after a pipe at the end of the code block, appends human-readable
#' labels to question codes present in your data. By default, `append_labels()`
#' searches for the codes in the "name" column. It is designed to to fit into
#' the dplyr select-and-pivot pipeline without the need to specify any additional arguments.
#' *The labels have to be sourced* first with the `extract_labels_from_ls` or `extract_labels_from_data` functions.*
#'
#' ```
#'
#' example_data %>%
#'     select(starts_with('example_prefix')) %>%
#'     pivot_longer(everything()) %>%
#'     count(name, value) %>%
#'     group_by(name) %>%
#'     summarise(proportion = n / sum(n), value = value) %>%
#'     append_labels()
#'
#' ```
#'
#' When working with multiple surveys, you can assign the extracted labels
#' to a variable and then use it in a call to `append_labels()`.
#'
#' You can also explicitly define the name of the column containing
#' question codes.
#'
#' ```
#'
#' survey1_labels <- extract_labels_from_data(survey1_number)
#' survey2_labels <- extract_labels_from_ls(survey2_number)
#'
#' example_data_from_survey2 %>%
#'     select(starts_with('example_prefix')) %>%
#'     pivot_longer(everything(), names_to = 'new_name') %>%
#'     count(name, value) %>%
#'     append_labels(survey2_labels, 'new_name')
#'
#' ```
#'
#' @export
append_labels <- function( df, colname='name',
                           source=enlabel_cache$codes_and_labels,
                           trim = FALSE) {

  df <- df %>% dplyr::left_join(source %>% dplyr::select(match, labels), # to be removed?
                                by = setNames('match', colname)) # join with target data

  # https://stackoverflow.com/questions/28399065/dplyr-join-on-by-a-b-where-a-and-b-are-variables-containing-strings

  if (trim) {

    df <- df %>%
      mutate(labels = ifelse( is.na((stringr::str_extract(labels, "\\[(.*?)\\]"))),
                              labels,
                              substr(
                                stringr::str_extract(labels, "\\[(.*?)\\]"),
                                2, nchar(stringr::str_extract(labels, "\\[(.*?)\\]"))-1)))
  }

  return(df)

}
