#!/usr/bin/perl

# imover-0.2
# Скрипт для переименования и сортировки фото и видеофайлов по дате съемки
# Михаил <ivanych> Иванов (m.ivanych@gmail.com)

use strict;
use warnings;
use Image::ExifTool qw(:Public);
use File::Path qw(make_path);
use File::Copy;

# Уведомление Growl
my $growl = 1;

# Папки, в которые будут загружаться фото и видео файлы
my %folder = (
'jpg' => '/Users/ivanych/Мои фотки',
'avi' => '/Users/ivanych/Мое видео',
'3gp' => '/Users/ivanych/Мое видео'
);

# Модели устройств
my $model = 'iphone|s2|s1|desire|a480';

my $type = join '|', map {"($_)"} keys %folder;

# Читаем файлы
while (<>) {
    chomp;
    
    # Обработка файла
    if ($_ =~ /$type$/i) {
        if (-e $_) {
            # Получить данные файла
            my ($exp, $dev, $path, $file) = get($_);
            
            # Переместить файл
            mov($_, $folder{$exp}, $dev, $path, $file);
            
            # Удалить оригинал
            unlink($_) || die "Невозможно удалить файл $_: $!";
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
    $path .= "$year/".join ('-', $year, $month, $day);
    
    # Файл
    my $file;
    $file .= join ('-', $year, $month, $day) . "_$num.$exp";
    
    return ($exp, $dev, $path, $file);
};

# Переместить файл
sub mov {
    my ($orig, $folder, $dev, $path, $file) = @_;
    
    # Папка
    make_path("$folder/$dev $path", {verbose => 1});
    
    #  Файл
    unless (-f "$folder/$dev $path/$file") {
        copy("$orig", "$folder/$dev $path/$file") || die "Невозможно скопировать файл $orig: $!";
        chmod(0400, "$folder/$dev $path/$file") || die "Невозможно изменить права файла $orig: $!";
    };
    
    # Сообщение на консоль (полное)
    print "$orig -> $folder/$dev $path/$file\n";
    
    # Уведомление Growl (краткое)
    if ( (-f "/usr/local/bin/growlnotify") && ($growl) ) {
        system ("growlnotify -a 'Image Capture' -t '$orig ($dev)' -m '$file'");
    };
};
