.onLoad <- function (lib, pkg) {
  RcppRngStream.init()
}

.onUnload <- function (libpath) {
  RcppRngStream.exit()
  library.dynam.unload("RcppRngStream", libpath)
}
