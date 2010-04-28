package DBICx::Sucrose::Parser;

use strict;
use warnings;

use Any::Moose;
use DBICx::Sucrose::Carp;

use String::Util qw/ :all /;

our $HAS;
BEGIN { $HAS = sub { # Table/Column Accessor
    my $caller = caller;
    my $name = shift;
    my $error = shift;
    $caller->meta->add_method( $name => sub {
        my $self = shift;
        if ( @_ ) {
            my $value = shift;
            croak $error if $error && ! defined $value;
            return $self->{data}->{$name} = $value;
        }
        else {
            my $value = $self->{data}->{$name};
            croak $error if $error && ! defined $value;
            return $value;
        }
    } );
} }

use DBICx::Sucrose::Schema;
use DBICx::Sucrose::Table;
use DBICx::Sucrose::Column;

use Mouse::Exporter;
Mouse::Exporter->setup_import_methods(
    as_is => [qw/
        Type Integer Int Text Blob 
        NotNull Null
    /],
    with => [ any_moose ],
);

for (qw/ Integer Number Text Blob /) {
    my $type = $_;
    __PACKAGE__->meta->add_method( $type => sub {
        return DBICx::Sucrose::Parser::Token->new( type => $type );
    } );
}
#*Int = \&Integer;

sub NotNull { return DBICx::Sucrose::Parser::Token->new( nullable => 0 ) }
sub Null { return DBICx::Sucrose::Parser::Token->new( nullable => 1 ) }

my %macro = (
    table => {
        id => sub {
        },
        uuid => sub {
        },
    },
    column => {
    },
);

sub _invoke_macro {
    my $category = shift;
    my $name = shift;
    my $target = shift;

    croak "Unknown macro category ($category)" unless my $macro_category = $macro{$category};
    croak "Unknown macro ($name)" unless my $macro = $macro_category->{$name};

    $macro->( $target, @_ );
}

sub _parse_table {
    my $table = shift;
    my @input = @_;

    my $column;
    while ( @input ) {
        if ( ! ref $input[0] ) {
            if ( hascontent $input[0] && $input[0] =~ m/^\w/) {
                my $name = shift @input;
                $table->column( $name =>
                    ( $column = DBICx::Sucrose::Column->new( table => $table, name => $name ) ) );
            }
            elsif ( hascontent $input[0] && $input[0] =~ s/^-//) {
                my $macro = shift @input;
                if ( $column )  { _invoke_macro column => $macro, $column }
                else            { _invoke_macro table => $macro, $table }
            }
            else {
                croak "Invalid table input (@input)";
            }
        }
        elsif ( blessed $input[0] && $input[0]->isa( 'DBICx::Sucrose::Parser::Token' ) ) {
            my $token = shift @input;
            if ( $column )  { $token->apply( $column ) }
            else            { $token->apply( $table ) }
        }
        else {
            croak "Invalid table input (@input)";
        }
    }
}

sub parse {
    my $self = shift;
    my $table = shift;
    my @input = @_;

    my $schema = DBICx::Sucrose::Schema->new( dbic_class => 'Schema' );

    while ( @input ) {
        if ( ! ref $input[0] && ref $input[1] eq 'ARRAY' && hascontent $input[0] ) {
            my $name = shift @input;
            my @table_input = @{ shift @input };
            my $table = DBICx::Sucrose::Table->new( schema => $schema, name => $name );
            $schema->_tables->{ $table->name } = $table;
            _parse_table $table => @table_input;
        }
        else {
            croak "Invalid input (@input)";
        }
    }

    return $schema;
}

package DBICx::Sucrose::Parser::Token;

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

