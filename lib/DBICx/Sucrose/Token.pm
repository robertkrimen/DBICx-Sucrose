package DBICx::Sucrose::Token;

use Moose;
use MooseX::AttributeHelpers;
use DBICx::Sucrose::Carp;

use overload
    '""' => \&as_string,
    fallback => 1,
;

has kind => qw/is ro required 1 isa Str/;
has value => qw/is ro required 1/;

sub as_string {
    my $self = shift;
    return join ' ', $self->kind, $self->value;
}

1;
