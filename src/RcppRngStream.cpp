#include <RcppRngStream.h>

namespace RcppRngStream {

  static Rng * default_stream, * current_stream;
  static double rn = 0.0;

  Rng::~Rng() {
    if (current_stream->id == this->id)
      current_stream = default_stream;
  }

  void Rng::set() {
    current_stream = this;
  }

  extern "C" {

    void r_create_current_stream()
    {
      default_stream = new Rng();
      current_stream = default_stream;
    }

    void r_remove_current_stream()
    {
      delete default_stream;
    }

    void r_set_user_random_seed(double * inseed) {
      double seed[6];
      for(int i=0; i<6; i++) {
	seed[i] = inseed[i];
      }
      Rng::SetPackageSeed(seed);
      default_stream->SetSeed(seed);
    }

    void r_get_user_random_seed(double * outseed) {
      double seed[6];
      default_stream->GetState(seed);
      for(int i=0; i<6; i++) {
	outseed[i] = (double)seed[i];
      }
    }

    void r_next_rng_substream() {
      default_stream->ResetNextSubstream();
    }

    double *user_unif_rand ()
    {
      if (!current_stream) {
	REprintf("user_unif_rand(): No stream created yet!");
	return NULL;
      }
      rn = current_stream->RandU01();
      return &rn;
    }

    void test_rstream2(double * x) {
      Rng * s1 = new Rng();
      Rng * s2 = new Rng();
      x[0]=WithRNG(s1,R::rexp(1.0));
      x[1]=WithRNG(s2,R::rexp(1.0));
      s1->ResetNextSubstream();
      x[2]=R::rexp(1.0);
      delete s1;
      delete s2;
    }

  } // extern "C"

} // namespace RcppRngStream

