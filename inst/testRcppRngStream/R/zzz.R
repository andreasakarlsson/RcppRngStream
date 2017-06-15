.onLoad <- function (lib, pkg) {
    RcppRngStream.init(PACKAGE="testRcppRngStream")
}

.onUnload <- function (libpath) {
  RcppRngStream.exit(PACKAGE="testRcppRngStream")
  library.dynam.unload("testRcppRngStream", libpath)
}
