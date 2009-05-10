package DBICx::Sucrose::Column;

use Moose;
use DBICx::Sucrose::Carp;

has table => qw/is ro required 1 isa DBICx::Sucrose::Table/;
has name => qw/is ro required 1/;

sub BUILD {
    my $self = shift;
}

1;
