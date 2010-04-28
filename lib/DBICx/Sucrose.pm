package DBICx::Sucrose;

use warnings;
use strict;

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';

use Any::Moose;
use DBICx::Sucrose::Carp;

use DBICx::Sucrose::Parser;

sub parse {
    return DBICx::Sucrose::Parser->new->parse( @_ );
}

1;
