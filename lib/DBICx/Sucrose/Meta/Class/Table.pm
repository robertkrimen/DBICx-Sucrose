package DBICx::Sucrose::Meta::Class::Table;

use strict;
use warnings;

use Moose;

extends qw/Moose::Meta::Class/;

has table => qw/is rw/;

1;
