#!/usr/bin/perl

#
# imover-0.1
# Скрипт для сортировки и каталогизации фото и видеофайлов по дате съемки
# Принимает список файлов на STDIN
# Переименовывает и перемещает файлы по маске "МодельФотоаппарата ГГГГ/ГГГГ-ММ-ДД/ГГГГ-ММ-ДД_номер.расширение"
# Автор - Михаил 'ivanych' Иванов (m.ivanych@gmail.com)
#

use strict;
use warnings;
use Image::ExifTool qw(:Public);
use File::Path qw(make_path);
use File::Copy;

# Папки, в которые будут загружаться фото и видео файлы
my %folder = (
    'jpg' => '/Users/ivanych/Мои фотки',
    'avi' => '/Users/ivanych/Мое видео',
    '3gp' => '/Users/ivanych/Мое видео'
);

# Модели устройств
my $model = 'iphone|s2|desire|a480';

my $type = join '|', map {"($_)"} keys %folder;

# Читаем файлы
while (<>) {
    chomp;
    
    # Обработка файла
    if ($_ =~ /$type$/i) {
        if (-e $_) {
            # Получить данные файла
            my ($exp, $path, $file) = get($_);
        
            # Перенести файл
            mov($_, $folder{$exp}, $path, $file);
        }
        else {
            print "$_ -> не найден\n";
        };
    }
    else {
        print "$_ -> игнор\n";
    };
};

# Получить данные файла
sub get {
    my ($orig) = @_;

    my $info = ImageInfo($orig);
    
    # Устройство (из списка известных моделей)
    my $dev;
    ($dev) = $info->{'Model'} =~ /($model)/i if !$dev && $info->{'Model'};
    ($dev) = 'Unknown' if !$dev;
    
    # Дата
    my ($year, $month, $day);
    ($year, $month, $day) = $info->{'DateTimeOriginal'} =~ /^(\d{4}).(\d{2}).(\d{2})/ if !$year && $info->{'DateTimeOriginal'};
    ($year, $month, $day) = $info->{'CreateDate'} =~ /^(\d{4}).(\d{2}).(\d{2})/ if !$year && $info->{'CreateDate'};
    ($year, $month, $day) = ('0000', '00', '00') if !$year;
    
    # Номер файла (последние цифры перед расширением или последние 4 цифры размера файла)
    my $num;
    ($num) = $orig =~ /(\d+)\..+?$/;
    ($num) = (-s $orig) =~ /(\d{1,4}$)/ if !$num;
    
    # Расширение (нижний регистр)
    my ($exp) = map {lc} $orig =~ /\.(.+?)$/;
    
    # Путь
    my $path;
    $path .= "$dev " if $dev;
    $path .= "$year/".join ('-', $year, $month, $day);
    
    # Файл
    my $file;
    $file .= join ('-', $year, $month, $day) . "_$num.$exp";
    
    return ($exp, $path, $file);
};

# Перенести файл
sub mov {
    my ($orig, $folder, $path, $file) = @_;

    # Папка
    make_path("$folder/$path", {verbose => 1});
  
    #  Файл
    unless (-f "$folder/$path/$file") {
        move("$orig", "$folder/$path/$file") || die "Невозможно перенести файл $orig: $!";
        chmod(0400, "$folder/$path/$file") || die "Невозможно изменить права файла $orig: $!"
    };

    # Сообщение
    print "$orig -> $folder/$path/$file\n";
};
