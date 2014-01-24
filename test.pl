#!/usr/bin/perl

use strict;
use warnings;

use Test::Harness;

my @tests = glob('t/*.t');
runtests(@tests);
