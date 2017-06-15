.onLoad <- function (lib, pkg) {
  if(.Platform$OS.type == "unix")
    RcppRngStream.init(PACKAGE="testRcppRngStream")
}

.onUnload <- function (libpath) {
  if(.Platform$OS.type == "unix")
    RcppRngStream.exit(PACKAGE="testRcppRngStream")
  library.dynam.unload("testRcppRngStream", libpath)
}
