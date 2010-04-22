package DBICx::Sucrose::Column;

use Moose;
use MooseX::AttributeHelpers;
use DBICx::Sucrose::Carp;

has table => qw/ is ro required 1 isa DBICx::Sucrose::Table /;
has name => qw/ is ro required 1 isa Str /;

has _tokens => qw/ init_arg tokens metaclass Collection::Array is ro required 1 isa ArrayRef /,
    default => sub { [] },
    provides => {qw/
        elements    tokens
        push        push_token
    /},
;


sub BUILD {
    my $self = shift;
}

sub attribute_hash {
    my $self = shift;

    my %hash;

    for my $token ( $self->token_list ) {
        if ( $token->kind eq 'type' ) {
            $hash{data_type} = $token->value;
        }
        elsif ( $token->kind eq 'nullable' ) {
            $hash{is_nullable} = $token->value;
        }
        else {
            croak "Don't understand token $token";
        }
    }

#    use XXX -dumper;
#    WWW \%hash;

    return \%hash;
}

1;
