use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Imover',
    AUTHOR    => 'Mikhail Ivanov <m.ivanych@gmail.com>',
    ABSTRACT  => 'Script for renaming and sorting photos and videos',
    VERSION_FROM => 'lib/Imover.pm',
    TEST_REQUIRES => {
        "Image::ExifTool" => "0",
    },
    PREREQ_PM => {
        "Image::ExifTool" => "0",
    },
    EXE_FILES => ['bin/imover'],
);
