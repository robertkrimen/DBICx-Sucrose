package DBICx::Sucrose::Token;

use strict;
use warnings;

use Any::Moose;
use DBICx::Sucrose::Carp;

has name => qw/ is ro required 1 isa Str /;
has value => qw/ is ro required 1 /;
has arguments => qw/ is ro isa Maybe[HashRef] /;

sub BUILDARGS {
    my $self = shift;
    return { @_ } unless @_ <= 3;
    my %given = ( name => shift, value => shift );
    $given{arguments} = shift if @_;
    return \%given;
}

sub apply {
    my $self = shift;
    my $target = shift;
    $target->data->{ $self->name } = $self->value;
}

1;
