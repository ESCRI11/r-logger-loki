#' @title Validate Log Arguments
#' @description Validates the arguments for logging.
#' @param log_message The log message as a character string.
#' @param log_labels The labels for the log as a list.
#' @keywords internal
validate_arguments <- function(log_message, log_labels) {
  if (!is.character(log_message) || length(log_message) != 1) {
    stop("log_message should be a single character string")
  }
  
  if (!is.list(log_labels)) {
    stop("log_labels should be a list")
  }
}

#' @title Get Loki Endpoint
#' @description Gets the Loki endpoint either from the function argument or the package environment.
#' @param loki_endpoint The endpoint URL as a string or NULL.
#' @param pkg_env The package environment containing global settings.
#' @return The Loki endpoint as a string.
#' @keywords internal
get_loki_endpoint <- function(loki_endpoint, pkg_env) {
  if (is.null(loki_endpoint)) {
    if (exists("loki_endpoint", envir = pkg_env)) {
      return(get("loki_endpoint", envir = pkg_env))
    } else {
      stop("No Loki endpoint provided and none is set in the package environment.")
    }
  }
  return(loki_endpoint)
}

#' @title Construct Payload for Loki
#' @description Constructs the payload to send to Loki.
#' @param log_message The log message as a character string.
#' @param log_labels The labels for the log as a list.
#' @param trace Traceback information as a character vector or NULL.
#' @return A list representing the payload.
#' @keywords internal
construct_payload <- function(log_message, log_labels, trace) {
  if (!is.null(trace)) {
    trace_str <- paste(trace, collapse = "; ")
    log_message <- paste(log_message, "\nTraceback: ", trace_str)
  }
  
  list(
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
}

#' @title Send Log to Loki
#' @description Sends the JSON payload to Loki and checks the response.
#' @param json_payload The JSON payload as a string.
#' @param loki_endpoint The Loki endpoint as a string.
#' @param async Logical indicating whether to send the log asynchronously.
#' @return Logical indicating whether the log was successfully sent, or a future promise.
#' @keywords internal
send_log_to_loki <- function(json_payload, loki_endpoint, async = FALSE) {
  if (async) {
    future::plan("multiprocess") # You can use other plans like "multisession" based on your needs
    promise <- future::future({
      httr::POST(
        loki_endpoint,
        body = json_payload,
        encode = "json",
        httr::add_headers("Content-Type" = "application/json")
      )
    }) %...>% {
      if (.@status_code == 204) {
        return(TRUE)
      } else {
        warning(paste0("Failed to send log to Loki: ", httr::content(., "text")))
        return(FALSE)
      }
    }
    return(promise)
  } else {
    response <- httr::POST(
      loki_endpoint,
      body = json_payload,
      encode = "json",
      httr::add_headers("Content-Type" = "application/json")
    )
  
    if (response$status_code == 204) {
      return(TRUE)
    } else {
      warning(paste0("Failed to send log to Loki: ", httr::content(response, "text")))
      return(FALSE)
    }
  }
}