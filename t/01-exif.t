#!/usr/bin/perl

use strict;
use warnings;

use File::Path qw(remove_tree);

use Test::More tests => 3;

# Модель/Дата(orig);
system('ls t/images/exif-model-origdate.jpg | ./imover.pl -c');
ok (-e "$ENV{HOME}/imover/Мои фотки/iPhone 2011/2011-11-11/2011-11-11_1546.jpg", 'Модель/Дата(orig)');

# неМодель/Дата(create);
system('ls t/images/exif-nomodel-createdate.jpg | ./imover.pl -c');
ok (-e "$ENV{HOME}/imover/Мои фотки/Super Camera X1 2012/2012-12-12/2012-12-12_3016.jpg", 'неМодель/Дата(create)');

# Пусто/Пусто;
system('ls t/images/exif-empty-empty.jpg | ./imover.pl -c');
ok (-e "$ENV{HOME}/imover/Мои фотки/Unknown 0000/0000-00-00/0000-00-00_1674.jpg", 'неМодель/Дата(create)');

# Удаление файлов
remove_tree("$ENV{HOME}/imover");
