#include <langinfo.h>
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "perliol.h"

/* Declarations from PerlIO::encoding */

typedef struct {
    PerlIOBuf base;		/* PerlIOBuf stuff */
    SV *bufsv;			/* buffer seen by layers above */
    SV *dataSV;			/* data we have read from layer below */
    SV *enc;			/* the encoding object */
    SV *chk;                    /* CHECK in Encode methods */
    int flags;			/* Flags currently just needs lines */
} PerlIOEncode;

extern IV PerlIOEncode_pushed(pTHX_ PerlIO*, const char*, SV*, PerlIO_funcs*);
extern IV PerlIOEncode_popped(pTHX_ PerlIO*);
extern SV *PerlIOEncode_getarg(pTHX_ PerlIO*, CLONE_PARAMS*, int flags);
extern PerlIO *PerlIOEncode_dup(pTHX_ PerlIO*, PerlIO*, CLONE_PARAMS*, int flags);
extern SSize_t PerlIOEncode_write(pTHX_ PerlIO*, const void*, Size_t count);
extern Off_t PerlIOEncode_tell(pTHX_ PerlIO*);
extern IV PerlIOEncode_close(pTHX_ PerlIO*);
extern IV PerlIOEncode_flush(pTHX_ PerlIO*);
extern IV PerlIOEncode_fill(pTHX_ PerlIO*);
extern STDCHAR *PerlIOEncode_get_base(pTHX_ PerlIO*);

/* End From PerlIO::encoding */

IV
PerlIOLocale_pushed(pTHX_ PerlIO *f, const char *mode, SV *arg, PerlIO_funcs *tab)
{
    /* It would be better to use the code from open::import() here
     * instead of relying on the availability of nl_langinfo. */
    /* Also, on some platforms CODESET might not be #defined, although it
     * should be in langinfo.h. */
    SV *locale_encoding = sv_2mortal(newSVpv(nl_langinfo(CODESET), 0));
    return PerlIOEncode_pushed(aTHX_ f, mode, locale_encoding, tab);
}

/* Inherit all functions, except Pushed, from PerlIO::encoding */

PerlIO_funcs PerlIO_locale = {
    sizeof(PerlIO_funcs),
    "locale",
    sizeof(PerlIOEncode),
    PERLIO_K_BUFFERED|PERLIO_K_DESTRUCT,
    PerlIOLocale_pushed,
    PerlIOEncode_popped,
    PerlIOBuf_open,
    NULL, /* binmode - always pop */
    PerlIOEncode_getarg,
    PerlIOBase_fileno,
    PerlIOEncode_dup,
    PerlIOBuf_read,
    PerlIOBuf_unread,
    PerlIOEncode_write,
    PerlIOBuf_seek,
    PerlIOEncode_tell,
    PerlIOEncode_close,
    PerlIOEncode_flush,
    PerlIOEncode_fill,
    PerlIOBase_eof,
    PerlIOBase_error,
    PerlIOBase_clearerr,
    PerlIOBase_setlinebuf,
    PerlIOEncode_get_base,
    PerlIOBuf_bufsiz,
    PerlIOBuf_get_ptr,
    PerlIOBuf_get_cnt,
    PerlIOBuf_set_ptrcnt,
};

MODULE = PerlIO::locale PACKAGE = PerlIO::locale

PROTOTYPES: ENABLE

BOOT:
    PerlIO_define_layer(aTHX_ &PerlIO_locale);
