.onLoad <- function (lib, pkg) {
  library.dynam("RcppRngStream", pkg, lib)
  .RcppRngStream.init()
}

.onUnload <- function (libpath) {
  .RcppRngStream.exit()
  library.dynam.unload("RcppRngStream", libpath)
}
