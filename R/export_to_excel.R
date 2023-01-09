#' Export data to Excel
#'
#' @param data A dataframe
#' @param varnames Variables
#' @param max_cat The maximum number of categories for a variable
#' @param bonferroni Bonferroni correction
#' @param filename Filename
#' @param overwrite Overwrite
#' @export
export_to_excel <- function(data,
                            varnames = list(),
                            max_cat = 15,
                            bonferroni = FALSE,
                            filename = paste0(deparse(substitute(data)), "_tables.xlsx" ),
                            overwrite = FALSE ) {

  # Banner
  banner = with(data, list(expss::total(), purrr::map(varnames, ~data[[.x]] ) )) # !

  # Create tables
  tables = lapply(data, function(variable) {
    if(length(unique(variable)) <= max_cat) {
      expss::cro_cpct(variable, banner) %>% expss::significance_cpct(bonferroni = bonferroni)
    } else if(is.numeric(variable)) {
      expss::cro_mean_sd_n(variable, banner) %>% expss::significance_means(bonferroni = bonferroni)
    }
  }) # This can sometimes throw an error that there are duplicate labels...

  wb = openxlsx::createWorkbook()
  sh = openxlsx::addWorksheet(wb, "Tables")

  # Write to excel
  expss::xl_write(tables, wb, sh,
           # remove '#' sign from totals
           col_symbols_to_remove = "#",
           row_symbols_to_remove = "#",
           # format total column as bold
           other_col_labels_formats = list("#" = openxlsx::createStyle(textDecoration = "bold")),
           other_cols_formats = list("#" = openxlsx::createStyle(textDecoration = "bold"))
  )

  openxlsx::saveWorkbook(wb, filename, overwrite = overwrite)

}
