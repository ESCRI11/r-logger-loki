# Create an environment to hold the package's global settings
pkg_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  assign("pkg_env", pkg_env, envir = asNamespace(pkgname))
}
