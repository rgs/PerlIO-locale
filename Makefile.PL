use 5.008;
use ExtUtils::MakeMaker;
use Config;

unless ($Config{useperlio} eq 'define' and $Config{usesfio} eq 'false') {
    die <<BARF;
You need perl 5.8.0 or later, configured to use perlio (and not to use sfio).
BARF
}
unless ($Config{dynamic_ext} =~ m,\bPerlIO/encoding\b,) {
    die <<BARF;
You need to have PerlIO::encoding built as a dynamic extension available.
BARF
}
unless ($Config{d_nl_langinfo} eq 'define') {
    die <<BARF;
This module doesn't support yet platforms that don't have nl_langinfo(3).
BARF
}

# Now, guess the location of the shared lib for PerlIO::encoding, from
# which PerlIO::locale inherits, so we must link with it. Looking it
# up in @DynaLoader::dl_shared_objects would be more reliable, but
# PerlIO::encoding uses XSLoader and as of 5.8.4 XSLoader doesn't update
# this array...
require PerlIO::encoding;
my $encoding_so = $INC{'PerlIO/encoding.pm'};
$encoding_so =~ s,\.pm\z,/encoding.$Config{dlext},;
$encoding_so =~ s,/PerlIO/,/auto/PerlIO/,;

-f $encoding_so or die "Can't find encoding.so (at $encoding_so)\n";
print "Found encoding.so at $encoding_so\n";

WriteMakefile(
    AUTHOR => 'Rafael Garcia-Suarez <rgarciasuarez@gmail.com>',
    MYEXTLIB => $encoding_so,
    NAME => 'PerlIO::locale',
    PREREQ_PM => { 'PerlIO::encoding' => 0 },
    VERSION_FROM => 'locale.pm',
    LICENSE => 'perl',
    clean => { FILES => "foo" },
);
