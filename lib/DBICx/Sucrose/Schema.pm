package DBICx::Sucrose::Schema;

use strict;
use warnings;

use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use DBICx::Sucrose::Carp;

has _tables => qw/ metaclass Collection::Hash is ro lazy_build 1 isa HashRef /;
sub _build__tables { {} }

sub table {
    my $self = shift;
    my $name = shift;
    my $table = $self->_tables->{$name} or croak "Invalid table ($name)";
    return $table;
}

has dbic_class => qw/ is rw isa Str required 1 /;

sub load {
    my $self = shift;

    my $class = $self->dbic_class;
    Mouse::Meta::Class->initialize( $class )->superclasses(qw/ DBIx::Class::Schema /);

    for my $table (values %{ $self->_tables }) {
        $table->load;
    }
}

1;
