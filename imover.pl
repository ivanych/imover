#!/usr/bin/perl

# imover-0.3
# Скрипт для переименования и сортировки фото и видеофайлов по дате съемки
# Михаил ivanych Иванов <m.ivanych@gmail.com>

use strict;
use warnings;
use Image::ExifTool qw(:Public);
use File::Path qw(make_path);
use File::Copy;
use Getopt::Std;

# Папки, в которые будут загружаться фото и видео файлы
my %folder = (
'jpg' => '/Volumes/Media/Мои фотки',
'avi' => '/Volumes/Media/Мое видео',
'3gp' => '/Volumes/Media/Мое видео',
'mp4' => '/Volumes/Media/Мое видео',
);

# Модели устройств
my $model = 'iphone|s2|s1|desire|a480|i9300|p690';

# Типы файлов
my $type = join '|', map {"($_)"} keys %folder;

# Флаги копирования и удаления
our ($opt_c, $opt_d);
getopts('cd');

# Читаем файлы
while (<STDIN>) {
    chomp;

    # Обработка файла
    if ($_ =~ /$type$/i) {
        if (-e $_) {
            # Получить данные файла
            my ($exp, $dev, $path, $file) = get($_);

            # Переместить файл
            mov($_, $folder{$exp}, $dev, $path, $file);

            # Удалить оригинал
            if($opt_c) {
                if ($opt_d) {
                    unlink($_) || die "Невозможно удалить файл $_: $!";
                }
                else {
                    print "не удален\n";
                }
            };
        }
        else {
            print "$_ - не найден\n";
        };
    }
    else {
        print "$_ - игнор\n";
    };
};

# Получить данные файла
sub get {
    my ($orig) = @_;

    my $info = ImageInfo($orig);

    # Устройство (из списка известных моделей)
    my $dev;
    ($dev) = $info->{'Model'} =~ /($model)/i if !$dev && $info->{'Model'};
    ($dev) = $info->{'Model'} if !$dev;
    ($dev) = 'Unknown' if !$dev;

    # Дата
    my ($year, $month, $day);
    ($year, $month, $day) = $info->{'DateTimeOriginal'} =~ /^(\d{4}).(\d{2}).(\d{2})/ if !$year && $info->{'DateTimeOriginal'};
    ($year, $month, $day) = $info->{'CreateDate'} =~ /^(\d{4}).(\d{2}).(\d{2})/ if !$year && $info->{'CreateDate'};
    ($year, $month, $day) = ('0000', '00', '00') if !$year;

    # Номер файла (последние 3-4 цифры перед расширением, либо последние 1-4 цифры размера файла)
    my $num;
    ($num) = $orig =~ /(\d{3,4})\..+?$/;
    ($num) = (-s $orig) =~ /(\d{1,4}$)/ if !$num;

    # Расширение (нижний регистр)
    my ($exp) = map {lc} $orig =~ /\.(.+?)$/;

    # Путь (год/год-месяц-день)
    my $path;
    $path .= "$year/".join ('-', $year, $month, $day);

    # Файл (год-месяц-день_номер.расширение)
    my $file;
    $file .= join ('-', $year, $month, $day) . "_$num.$exp";

    return ($exp, $dev, $path, $file);
};

# Переместить файл
sub mov {
    my ($orig, $folder, $dev, $path, $file) = @_;

    # Сообщение на консоль (полное)
    print "$orig -> $folder/$dev $path/$file\n";

    if ($opt_c) {
        # Папка
        make_path("$folder/$dev $path", {verbose => 1});

        #  Файл
        unless (-f "$folder/$dev $path/$file") {
            copy("$orig", "$folder/$dev $path/$file") || die "Невозможно скопировать файл $orig: $!";
            chmod(0400, "$folder/$dev $path/$file") || die "Невозможно изменить права файла $orig: $!";
        };
    }
    else {
        print "не перемещен\n";
    }
};
