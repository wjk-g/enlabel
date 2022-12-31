#' Connect to LimeSurvey API
#'
#' `connect2ls()` allows you to connect to LimeSurvey RemoteControl API.
#' It uses a modified version of the `limer` library to establish connection.
#'
#' The creators of `limer` no longer maintain it.
#' An up-to-date version of the package, compatible with the latest versions of LimeSurvey,
#' can be installed directly from my github `devtools::install_github("wjk-g/limer")`.
#'
#' @param lime_username Your LimeSurvey username.
#' @param lime_password Your LimeSurvey password.
#' @param url LimeSurvey RemoteControl API 2 url.
#' @export
connect2ls <- function(lime_username, lime_password,
                       url="https://badania.stocznia.org.pl/index.php?r=admin/remotecontrol"
                       ) {
  options(lime_api = url)
  options(lime_username = lime_username )
  options(lime_password = lime_password )
  limer::get_session_key() # Log in
}
