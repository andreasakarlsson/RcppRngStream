LdFlags <- function()
    cat(system.file("lib/libRcppRngStream.a",  package="RcppRngStream", mustWork=TRUE))

RcppRngStream.init <- function (PACKAGE="RcppRngStream") {
  .Call("r_create_current_stream",PACKAGE=PACKAGE)
  return(1)
}

RcppRngStream.exit <- function (PACKAGE="RcppRngStream") {
  .Call("r_remove_current_stream",PACKAGE=PACKAGE)
  return(1)
}
## http://r.789695.n4.nabble.com/How-to-construct-a-valid-seed-for-l-Ecuyer-s-method-with-given-Random-seed-td4656340.html
unsigned <- function(seed) ifelse(seed < 0, seed + 2^32, seed)
signed <- function(seed) ifelse(seed>2^31, seed-2^32, seed)

set.user.Random.seed <- function (seed, PACKAGE="RcppRngStream") {
  seed <- as.double(unsigned(seed))
  if (length(seed) == 1) seed <- rep(seed,6)
  if (length(seed) == 7) seed <- seed[-1]
  .C("r_set_user_random_seed",seed = seed,PACKAGE=PACKAGE)
  return(invisible(seed))
}

next.user.Random.substream <- function (PACKAGE="RcppRngStream") {
  .C("r_next_rng_substream",PACKAGE=PACKAGE)
  return(invisible(TRUE))
}

user.Random.seed <- function(PACKAGE="RcppRngStream") {
  c(407L,
    as.integer(signed(.C("r_get_user_random_seed", seed=as.double(rep(1,6)),
                         PACKAGE=PACKAGE)$seed)))
}

RNGstate <- function() {
  ## house-keeping for random streams (see parallel::clusterSetRNGStream)
  oldseed <- if (exists(".Random.seed", envir = .GlobalEnv,
                        inherits = FALSE))
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  else NULL
  reset <- function() {
    if (!is.null(oldseed))
      assign(".Random.seed", oldseed, envir = .GlobalEnv)
    else {
        ## clean up if we created a .Random.seed
        if (exists(".Random.seed" ,envir = .GlobalEnv, inherits = FALSE))
            rm(.Random.seed, envir = .GlobalEnv, inherits = FALSE)
    }
  }
  list(oldseed = oldseed, reset = reset)
}

RNGStream <- function(nextStream = TRUE, iseed = NULL) {
  stopifnot(exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE) || !is.null(iseed))
  oldseed <- if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  else NULL
  if (RNGkind()[1] != "L'Ecuyer-CMRG") RNGkind("L'Ecuyer-CMRG")
  if (!is.null(iseed)) set.seed(iseed)
  current <- if (nextStream) parallel::nextRNGStream(.Random.seed) else .Random.seed
  .Random.seed <<- startOfStream <- startOfSubStream <- current
  structure(list(resetRNGkind = function() {
      if (!is.null(oldseed))
          assign(".Random.seed", oldseed, envir = .GlobalEnv)
      else rm(.Random.seed, envir = .GlobalEnv)
  },
                 seed = function() current,
                 open = function() .Random.seed <<- current,
                 close = function() current <<- .Random.seed,
                 resetStream = function() .Random.seed <<- current <<- startOfSubStream <<- startOfStream,
                 resetSubStream = function() .Random.seed <<- current <<- startOfSubStream,
                 nextSubStream = function() .Random.seed <<- current <<- startOfSubStream <<- parallel::nextRNGSubStream(startOfSubStream),
                 nextStream = function() .Random.seed <<- current <<- startOfSubStream <<- startOfStream <<- parallel::nextRNGStream(startOfStream)),
            class="RNGStream")
  }

with.RNGStream <- function(data,expr,...) {
  data$open()
  out <- eval(substitute(expr), enclos = parent.frame(), ...)
  data$close()
  out
}
setOldClass("RNGStream")
