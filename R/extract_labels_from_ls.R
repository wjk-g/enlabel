#' Extract question labels from LimeSurvey
#'
#' The function extracts variable descriptions from LimeSurvey.
#'
#' Connecting to LimeSurvey and downloading the necessary data can
#' take between 10 and 20 seconds, depending on a survey.
#'
#' @section Example:
#'
#' ```
#' connect2ls('your_username', 'your_password', 'ls_url')
#'
#' # Import without assigning to variable
#' extract_labels_from_ls(survey_number)
#'
#' # Import and assign to a variable (useful when working with multiple surveys)
#' labels_for_survey_1 <- extract_labels_from_ls(survey_1_number)
#' labels_for_survey_2 <- extract_labels_from_ls(survey_2_number)
#'
#' ```
#'
#' @param svyid id number of a LimeSurvey survey.
#' @export
extract_labels_from_ls <- function(svyid) {

  questions <- limer::call_limer(method = 'list_questions',
                          params = list(iSurveyID = svyid))

  enlabel_cache$questions <- questions

  ls_raw_question_data <- list()

  for (id in questions$id) {
    q <- limer::call_limer(method = 'get_question_properties',
                    params = list(iQuestionID = id,
                                  aQuestionSettings = list('qid', 'parent_qid',
                                                           'question_theme_name',
                                                           'available_answers',
                                                           'title')))
    ls_raw_question_data <- append(ls_raw_question_data, list(q)) # '<<-' assigns var to global env
  }
  #enlabel_cache$ls_raw_question_data <- ls_raw_question_data
  #invisible(ls_raw_question_data)

  codes_and_labels <- purrr::map_df(ls_raw_question_data, ~ tibble::tibble(
    qid = .x$qid, # check
    code = names(.x$available_answers),
    labels = .x$available_answers,
    title = .x$title,
    type = .x$question_theme_name) %>%
      tidyr::unnest(labels) ) # converts answer options into a dataframe

  codes_and_labels <- codes_and_labels %>%
    dplyr::mutate(match = ifelse(!is.na(code), # ensures that single choice questions witch don't have the code property are coded properly
                                 paste0(title, '_', code),
                                 title)) %>% # creates a match column for a join with target data
    dplyr::select(qid, match, labels)

  enlabel_cache$codes_and_labels <- codes_and_labels

  return(codes_and_labels)
}

if (!exists("enlabel_cache", mode="environment")) {
  enlabel_cache <- new.env(parent = emptyenv())
}

