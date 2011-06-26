#include <langinfo.h>
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "perliol.h"

IV
PerlIOLocale_pushed(pTHX_ PerlIO *f, const char *mode, SV *arg, PerlIO_funcs *tab)
{
    PerlIO_funcs* encoding = PerlIO_find_layer(aTHX_ "encoding", 8, 1);
    SV* locale_encoding = sv_2mortal(newSVpv(nl_langinfo(CODESET), 0));
    return PerlIO_push(aTHX_ f, encoding, mode, locale_encoding) == f ? 0 : -1;
}

PerlIO_funcs PerlIO_locale = {
    sizeof(PerlIO_funcs),
    "locale",
    0,
    0,
    PerlIOLocale_pushed,
    NULL,
#if PERL_VERSION >= 14
    PerlIOBase_open,
#else
    PerlIOBuf_open,
#endif
};

MODULE = PerlIO::locale PACKAGE = PerlIO::locale

BOOT:
    PerlIO_define_layer(aTHX_ &PerlIO_locale);
