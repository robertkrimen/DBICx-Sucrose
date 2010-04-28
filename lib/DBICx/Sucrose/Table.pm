package DBICx::Sucrose::Table;

use strict;
use warnings;

use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use DBICx::Sucrose::Carp;

use DBICx::Sucrose::Parser;
my $HAS = $DBICx::Sucrose::Parser::HAS;

has schema => qw/ is ro required 1 weak_ref 1 /;

has data => qw/ is ro isa HashRef lazy_build 1 /;
sub _build_data { {} }

$HAS->( 'name' => 'Missing name' );

sub BUILD {
    my $self = shift;
    my $given = shift;
    defined $given->{$_} and ( $self->data->{ $_ } = $given->{$_} ) for qw/ name /;
}

#has _columns => qw/ metaclass Collection::Array is ro required 1 isa ArrayRef /,
#    default => sub { [] },
#    provides => {qw/
#        elements    columns
#        push        add_column
#    /}
#;
has _columns => qw/ metaclass Collection::Hash is ro lazy_build 1 isa HashRef /;
sub _build__columns { {} }

sub column {
    my $self = shift;
    my $name = shift;
    if ( @_ ) {
        croak "Existing column ($name)" if $self->_columns->{$name};
        $self->_columns->{$name} = shift;
    }
    else {
        my $column = $self->_columns->{$name} or croak "Invalid column ($name)";
        return $column;
    }
}

sub load {
    my $self = shift;

    my $class = $self->dbic_class;
    Mouse::Meta::Class->initialize( $class )->superclasses(qw/ DBIx::Class /);
    my $schema_class = $self->schema->dbic_class;

    $class->load_components( $self->dbic_load_components );
    $class->table( $self->dbic_table );

    for my $column (values %{ $self->_columns }) {
        $column->load;
    }

    $schema_class->register_class( $self->name, $class );
}

has __dbic_load_components => qw/ metaclass Collection::Array is rw lazy_build 1 isa ArrayRef /,
    provides => {qw/
        elements    _dbic_load_components
    /}
;
sub _build___dbic_load_components { [qw/ ? /] }

sub dbic_load_components {
    my $self = shift;
    return map { $_ ne '?' ? $_ : qw/ PK::Auto Core / } $self->_dbic_load_components;
}

has dbic_class => qw/ is rw isa Str lazy_build 1 /;
sub _build_dbic_class {
    my $self = shift;
    return join '::', $self->schema->dbic_class, 'Result', $self->name;
}
#    # TODO X::
#    Mouse::Meta::Class->initialize( $class );
#    return $class;
#}

has dbic_table => qw/ is rw isa Str lazy_build 1 /;
sub _build_dbic_table {
    my $self = shift;

    my $name = $self->name;
    my $table = lc $name;
    $table =~ s/::/_/g;

    croak "Going from name \"$name\" to table \"$table\" looks weird" if $table =~ m/[^\w_\.]/;

    return $table;
}

1;
