use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME  => 'imover',
    PREREQ_PM => {
        "Image::ExifTool" => "0",
    },
    test  => {TESTS => 't/*.t'},
);
