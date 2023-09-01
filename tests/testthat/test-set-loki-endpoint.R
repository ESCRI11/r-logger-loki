context("set_loki_endpoint")

test_that("set_loki_endpoint sets the Loki endpoint correctly", {
  set_loki_endpoint("http://new-loki-endpoint")

  pkg_env <- getFromNamespace("pkg_env", "rLoggerLoki")
  expect_equal(get("loki_endpoint", envir = pkg_env), "http://new-loki-endpoint")
})