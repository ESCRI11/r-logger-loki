#' @title Log Messages to Loki with Custom Labels
#' @description This function allows you to send log messages from R to a Loki instance with custom labels.
#' @param log_message Character string specifying the log message.
#' @param log_labels Named list specifying the labels you want to add to the log.
#' @param loki_endpoint Character string specifying the URL of the Loki instance to send logs to.
#' @param trace Optional, character vector containing the traceback information. Default is NULL.
#' @param async Logical indicating whether to send the log asynchronously. Default is TRUE.
#' @return A list containing the HTTP response information from Loki, or a future promise if async is TRUE.
#' @examples
#' \dontrun{
#' log_to_loki("This is a test log", list(app = "MyApp", level = "INFO"), "http://your-loki-instance:3100/loki/api/v1/push")
#' log_to_loki("This is an error", list(app = "MyApp", level = "ERROR"), "http://your-loki-instance:3100/loki/api/v1/push", trace = traceback(2, as.character = TRUE))
#' }
#' @export
log_to_loki <- function(log_message, log_labels, loki_endpoint = NULL, trace = NULL, async = TRUE) {
  # Fetch the package environment
  pkg_env <- getFromNamespace("pkg_env", "rLoggerLoki")

  # Validate arguments
  validate_arguments(log_message, log_labels)

  # Get Loki endpoint
  loki_endpoint <- get_loki_endpoint(loki_endpoint, pkg_env)

  # Construct payload
  payload <- construct_payload(log_message, log_labels, trace)

  # Convert payload to JSON
  json_payload <- jsonlite::toJSON(payload, auto_unbox = TRUE)

  # Send log to Loki
  send_log_to_loki(json_payload, loki_endpoint)
}