package DBICx::Sucrose::Column;

use strict;
use warnings;

use Any::Moose;
use DBICx::Sucrose::Carp;

use DBICx::Sucrose::Parser;
my $HAS = $DBICx::Sucrose::Parser::HAS;

has schema => qw/ is ro lazy_build 1 weak_ref 1 /;
sub _build_schema { shift->table->schema }
has table => qw/ is ro required 1 weak_ref 1 /;

has data => qw/ is ro isa HashRef lazy_build 1 /;
sub _build_data { {} }

$HAS->( 'name' => 'Missing name' );
$HAS->( 'type' => 'Missing type' );
$HAS->( 'nullable' );

sub BUILD {
    my $self = shift;
    my $given = shift;
    defined $given->{$_} and ( $self->data->{ $_ } = $given->{$_} ) for qw/ name type nullable /;
}

sub load {
    my $self = shift;
    $self->table->dbic_class->add_column(
        $self->name, {
            data_type => $self->type,
            nullable => $self->nullable,
        },
    );
}

1;
