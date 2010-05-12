package DBICx::Sucrose;
# ABSTRACT: Syntactic sugar for DBIx::Class

use Any::Moose;
use DBICx::Sucrose::Carp;

use DBICx::Sucrose::Parser;

sub parse {
    return DBICx::Sucrose::Parser->new->parse( @_ );
}

1;
