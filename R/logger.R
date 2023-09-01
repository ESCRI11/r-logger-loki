#' Log Messages to Loki with Custom Labels
#'
#' This function allows you to send log messages from R to a Loki instance with custom labels.
#' The function constructs the payload and sends it to the specified Loki endpoint.
#'
#' @param log_message Character string specifying the log message.
#' @param log_labels Named list specifying the labels you want to add to the log.
#' @param loki_endpoint Character string specifying the URL of the Loki instance to send logs to.
#' @param trace Optional, character vector containing the traceback information. Default is NULL.
#'
#' @return A list containing the HTTP response information from Loki.
#' @export
#'
#' @examples
#' \dontrun{
#' log_to_loki("This is a test log", list(app = "MyApp", level = "INFO"), "http://your-loki-instance:3100/loki/api/v1/push")
#' log_to_loki("This is an error", list(app = "MyApp", level = "ERROR"), "http://your-loki-instance:3100/loki/api/v1/push", trace = traceback(2, as.character = TRUE))
#' }
log_to_loki <- function(log_message, log_labels, loki_endpoint = NULL, trace = NULL) {
  # Validate arguments
  if (!is.character(log_message) || length(log_message) != 1) {
    stop("log_message should be a single character string")
  }

  if (!is.list(log_labels)) {
    stop("log_labels should be a list")
  }

  # Fetch the package environment
  pkg_env <- getFromNamespace("pkg_env", "rLoggerLoki")
  
  # If no explicit endpoint provided, try to fetch from package environment
  if (is.null(loki_endpoint)) {
    if (exists("loki_endpoint", envir = pkg_env)) {
      loki_endpoint <- get("loki_endpoint", envir = pkg_env)
    } else {
      stop("No Loki endpoint provided and none is set in the package environment.")
    }
  }

  if (!is.null(trace) && !is.character(trace)) {
    stop("trace should be NULL or a character vector")
  }

  # Combine traceback with the log message if available
  if (!is.null(trace)) {
    trace_str <- paste(trace, collapse = "; ")
    log_message <- paste(log_message, "\nTraceback: ", trace_str)
  }

  # Construct the payload for Loki
  payload <- list(
    streams = list(
      list(
        stream = log_labels,
        values = list(list(
            as.character(as.numeric(Sys.time()) * 1e9),
            log_message
        ))
      )
    )
  )

  # Convert payload to JSON
  json_payload <- jsonlite::toJSON(payload, auto_unbox = TRUE)

  # Send the log to Loki
  response <- httr::POST(
    loki_endpoint,
    body = json_payload,
    encode = "json",
    httr::add_headers("Content-Type" = "application/json")
  )

  # Check response
  if (response$status_code == 204) {
    return(TRUE)
  } else {
    warning(paste0("Failed to send log to Loki: ", content(response, "text")))
    return(FALSE)
  }
}