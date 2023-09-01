#' Set Loki Endpoint for rLoggerLoki
#'
#' This function sets the Loki endpoint that will be used for logging by the
#' \code{\link{log_to_loki}} function when no endpoint is explicitly provided.
#'
#' @param endpoint A character string specifying the URL of the Loki endpoint.
#'   This should include the protocol (usually 'http') and the domain name or IP address.
#'   Optionally, the port number can also be included.
#' @examples
#' \dontrun{
#' set_loki_endpoint("http://your-loki-instance:3100")
#' }
#' @export
set_loki_endpoint <- function(endpoint) {
  pkg_env <- getFromNamespace("pkg_env", "rLoggerLoki")
  if (!is.character(endpoint) || length(endpoint) != 1) {
    stop("The endpoint must be a single character string.")
  }
  assign("loki_endpoint", endpoint, envir = pkg_env)
}