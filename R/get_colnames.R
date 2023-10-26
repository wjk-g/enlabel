
#' Get variable descriptions
#'
#' Produces a character vector of human-readable question labels
#' @description
#' This functions takes a dataframe as an input and returns a vector of variable descriptions.
#' You can use `get_colnames()` boh on 'unspoiled' and modified dataframes,
#' i.e. LimeSurvey or SPSS survey files that have had variables removed, renamed,
#' added or otherwise changed. If a variable does not have a match in the dataframe
#' supplied to `source`, its name will be used as a label.
#'
#' The main goal of `get_colnames()` is to prepare your data for export, e.g.
#' to Excel with the `expss` package.
#'
#' @param df A dataframe to be labelled.
#' @param source A dataframe containing question labels.
#' @param trim If `TRUE`, `get_colnames()` will attempt to include only the subquestion text
#' and discard the parent-question text.
#' @export
get_colnames <- function(df, source=enlabel_cache$codes_and_labels, trim = FALSE) {

  if ('qid' %in% names(source)) {

  full_question_data <- enlabel_cache$questions %>% dplyr::left_join(source, by = 'qid') # you need to create 2 paths for spss and ls imported data

  full_question_data <- full_question_data %>%
    dplyr::mutate(question = gsub("<[^>]*>", "", question) ) %>% # removes the stuff between < > (e.g. js scripts)
    dplyr::mutate(question = gsub("\\$\\(document\\).*", "", question) ) # removes $(document)

  if (trim) {

    full_question_data <- full_question_data %>%
      dplyr::mutate(label = ifelse(labels != "No available answers",
                                   labels,
                                   question ))
  } else {

    full_question_data <- full_question_data %>%
      dplyr::mutate(label = ifelse(labels != "No available answers",
                                   paste0(question, " ", labels),
                                   question ))
  }

  labels <- list()

  for (n in names(df)) {
    if (n %in% full_question_data[['match']]) {
      lab <- full_question_data[['label']][full_question_data[['match']] == n]
      labels <- append(labels, lab)
    } else {
      labels <- append(labels, n)
    }
  }

  } else {

    labels <- list()

    for (n in names(df)) {
      if (n %in% attributes(source)$variable.labels) {
        lab <- attributes(source)$variable.labels[names(source) == n]
        labels <- append(labels, lab)
      } else {
        labels <- append(labels, n)
      }
    }

  }

  unlist(labels)
}
