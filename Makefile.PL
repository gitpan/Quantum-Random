use strict;
use inc::Module::Install;

name('Quantum-Random');
version_from('lib/Quantum/Random.pm');
abstract('Optical quantum random number generator front-end');
author('Adam J. Foxson <afoxson@pobox.com>');
license('gpl');

check_nmake();

&Meta->write;
&Build->write if lc($0) eq 'build.pl';
&Makefile->write if lc($0) eq 'makefile.pl';
