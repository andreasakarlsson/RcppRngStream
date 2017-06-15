#include <RcppRngStream.h>

RcppExport SEXP testRcppRngStream() {
  double seed[6] = {12345.0, 12345.0, 12345.0, 12345.0, 12345.0, 12345.0};
  RcppRngStream::r_set_user_random_seed(seed);
  double x = R::runif(0.0, 1.0);
  return Rcpp::wrap(x);
}
