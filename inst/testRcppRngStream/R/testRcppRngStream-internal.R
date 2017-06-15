
test <- function() {
    base::RNGkind("user")
    set.user.Random.seed(12345)
    runif(2)
    }

test2 <- function() {
    base::RNGkind("user")
    .Call("testRcppRngStream",PACKAGE=packageName())
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
