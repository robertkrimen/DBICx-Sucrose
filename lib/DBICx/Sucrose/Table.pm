package DBICx::Sucrose::Table;

use Moose;
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

has _components_list => qw/metaclass Collection::Array is rw isa ArrayRef/, default => sub { [] }, provides => {qw/
    elements    _components
/};
sub load_components {
    my $self = shift;
    $self->_components_list( [ @_ ] );
#            $self->load(qw/InflateColumn::DateTime PK::Auto Core/, @_);
}

sub table {
    my $self = shift;
    my $name = shift;
    $self->load({ standard => 1 }) unless $self->did_load;
    $self->class->table( $name );
}

sub register {
    my $self = shift;
    $self->schema_class->register_class( $self->moniker, $self->class );
}

sub column {
    my $self = shift;
    my $name = shift;
    return $self->_column_map->{$name} ||= DBICx::Sucrose::Column->new( table => $self, name => $name );
}

1;
