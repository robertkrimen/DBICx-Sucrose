use inc::Module::Install;

name     'DBICx-Sucrose';
all_from 'lib/DBICx/Sucrose.pm';
author   'Robert Krimen <rkrimen@cpan.org>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

