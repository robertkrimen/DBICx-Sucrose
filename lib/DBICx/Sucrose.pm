package DBICx::Sucrose;
# ABSTRACT: Syntactic sugar for DBIx::Class

use Any::Moose;
use DBICx::Sucrose::Carp;

use DBICx::Sucrose::Parser;

use Package::Pkg;

pkg->export(map { $_ => "<DBICx::Sucrose::Parser::$_" }
    qw/ Integer Text Blob Null NotNull Unique /);

sub parse {
    return DBICx::Sucrose::Parser->new->parse( @_ );
}

1;
