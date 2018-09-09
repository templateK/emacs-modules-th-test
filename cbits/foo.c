#include "HsFFI.h"
#include "Rts.h"

#include <FLib_stub.h>

HsBool init(void) {
  int argc = 0;
  char *argv[] = { NULL };
  char **pargv = argv;

  // Initialize Haskell runtime
  {
    RtsConfig conf = defaultRtsConfig;
    conf.rts_opts_enabled = RtsOptsAll;
    hs_init_ghc(&argc, &pargv, conf);
  }
  // hs_init(NULL, NULL);
  someFuncfromFlib();

  return HS_BOOL_TRUE;
}

void deinit(void) {
  hs_exit();
}
