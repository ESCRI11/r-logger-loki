context("Internal Functions of rLoggerLoki")

# Testing validate_arguments
test_that("validate_arguments checks types and values", {
  expect_error(validate_arguments(123, list()), "log_message should be a single character string")
  expect_error(validate_arguments("log", "label"), "log_labels should be a list")
  expect_silent(validate_arguments("log", list(label1 = "info")))
})

# Testing construct_payload
test_that("construct_payload constructs payload properly", {
  payload <- construct_payload("Test log", list(app = "MyApp", level = "INFO"), trace = NULL)
  expect_equal(length(payload$streams), 1)
  expect_true(is.list(payload$streams[[1]]$stream))
  expect_equal(payload$streams[[1]]$stream$app, "MyApp")
  expect_equal(payload$streams[[1]]$stream$level, "INFO")
  expect_true(grepl("^\\d{19}$", payload$streams[[1]]$values[[1]][[1]]))
})