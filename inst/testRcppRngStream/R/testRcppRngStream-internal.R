if(.Platform$OS.type == "unix") {
    STATICPACKAGE <- "testRcppRngStream"
    set.user.Random.seed <- function (seed) 
        RcppRngStream::set.user.Random.seed(seed,STATICPACKAGE)
    next.user.Random.substream <- function () 
        RcppRngStream::next.user.Random.substream(STATICPACKAGE)
    user.Random.seed <- function() 
        RcppRngStream::user.Random.seed(STATICPACKAGE)
}

test <- function() {
    base::RNGkind("user")
    set.user.Random.seed(12345)
    runif(2)
    }

test2 <- function() {
    base::RNGkind("user")
    .Call("testRcppRngStream",PACKAGE="testRcppRngStream")
    }

## testing the user-defined random number generator
checkOutputs <- function() {
    init.seed <- as.integer(c(407,rep(12345,6)))
    RNGkind("user")
    set.user.Random.seed(init.seed)
    testA <- runif(2)
    next.user.Random.substream()
    testB <- runif(2)
    set.user.Random.seed(parallel::nextRNGStream(init.seed))
    newSeed <- user.Random.seed()
    testC <- runif(2)
    set.user.Random.seed(parallel::nextRNGStream(newSeed))
    testD <- runif(2)
    as.list(environment())
    }
##
