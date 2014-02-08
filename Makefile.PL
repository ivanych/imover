use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'imover',
    AUTHOR    => 'Mikhail Ivanov <m.ivanych@gmail.com>',
    ABSTRACT  => 'Script for renaming and sorting photos and videos',
    VERSION   => '0.5',
    TEST_REQUIRES => {
        "Image::ExifTool" => "0",
    },
    PREREQ_PM => {
        "Image::ExifTool" => "0",
    },
    EXE_FILES => ['bin/imover'],
);
