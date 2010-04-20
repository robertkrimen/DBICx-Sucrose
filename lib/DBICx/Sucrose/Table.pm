package DBICx::Sucrose::Table;

use Any::Moose;
use Any::Moose 'X::AttributeHelpers';
use DBICx::Sucrose::Carp;

use DBICx::Sucrose::Column;

has schema_class => qw/is ro required 1/;
has moniker => qw/is ro required 1/;
has class => qw/is ro required 1/;
has class_meta => qw/is ro lazy_build 1/;
sub _build_class_meta {
    return shift->class->meta;
}

has _column_map => qw/is ro required 1 isa HashRef/, default => sub { {} };
sub column {
    my $self = shift;
    my $name = shift;
    my @given = @_;
    return $self->_column_map->{$name} ||= do {
        my @token_list;
        for (@given) {
            next unless blessed $_ && $_->isa( 'DBICx::Sucrose::Token' );
            push @token_list, $_;
        }
        my $column = DBICx::Sucrose::Column->new( table => $self, name => $name, _token_list => \@token_list );
        $self->push_column( $column );
        $column;
    };
}
has _column_list => qw/metaclass Collection::Array is ro required 1 isa ArrayRef/, default => sub { [] }, provides => {qw/
    elements    column_list
    push        push_column
/};

has name => qw/is rw isa Str/;

has _component_list => qw/is rw isa ArrayRef/;
sub load_components {
    my $self = shift;
    $self->_component_list( [ @_ ] );
}
sub component_list {
    my $self = shift;
    
    return @{ $self->_component_list } if $self->_component_list;

#   qw/InflateColumn::DateTime PK::Auto Core/;
    return qw/ PK::Auto Core /;
}

sub register {
    my $self = shift;

    $self->class->load_components( $self->component_list );
    $self->class->table( $self->name );

    $self->class->add_columns( map { $_->name => $_->attribute_hash } $self->column_list );

    $self->schema_class->register_class( $self->moniker, $self->class );
}

1;
