package DBICx::Sucrose;

use warnings;
use strict;

=head1 NAME

DBICx::Sucrose - The great new DBICx::Sucrose!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    package My::Schema;

    use DBICx::Sucrose;

    table( 'Xyzzy', [

        id      => Integer, PrimaryKey,
        apple   => Text,
        banana  => Text, NotNull,
        cherry  => Blob, Null,

        sub {
        },

    ] );

=cut

use strict;
use warnings;

use Any::Moose;
use DBICx::Sucrose::Carp;

use DBICx::Sucrose::Table;
use DBICx::Sucrose::Token;
use DBICx::Sucrose::Meta::Class::Table;

use Class::MOP;
use DBIx::Class();
use Try::Tiny;
use Carp;

our ( $Table );

use Mouse::Exporter;
Mouse::Exporter->setup_import_methods(
    as_is => [qw/
        table
        column unique commit
        has_many belongs_to has_one
        Type Integer Int Text Blob 
        NotNull Null
    /],
    with => [ any_moose ],
);

#Moose::Exporter->setup_import_methods(
#    with_caller => [qw/ table /],
#    as_is => [qw/
#        column unique commit
#        has_many belongs_to has_one
#        Type Integer Int Text Blob 
#        NotNull Null
#    /],
#    also => [qw/ Moose /],
#);
##    ( with_caller => [qw( has_table has_policy has_one has_many transform )],
##      as_is       => [qw( inflate deflate handles )],
##      also        => 'Moose'
##    );

sub init_meta {
    shift;

    return Moose->init_meta( @_, base_class => 'DBIx::Class::Schema' );
}

sub _Table() {
    return $Table or croak "No table \"in scope\"!";
}

sub _moniker_to_table_name {
    my $self = shift;
    my $moniker = shift;

    my $table_name = lc $moniker;
    $table_name =~ s/::/_/g;

    croak "Going from moniker \"$moniker\" to table name \"$table_name\" looks weird" if $table_name =~ m/[^\w_\.]/;

    return $table_name;
}

sub table {
    my $caller = caller;
    if ($Table) {
        _Table->table( @_ );
    }
    else {
        my $moniker = shift;
        my $table_name;
        if (@_ && ! ref $_[0]) {
            $table_name = shift;
        }
        $table_name ||= __PACKAGE__->_moniker_to_table_name( $moniker );

        my $Table_class = join '::', $caller, 'Result', $moniker;
        my $Table_class_meta = Moose->init_meta( for_class => $Table_class, base_class => 'DBIx::Class', metaclass => 'DBICx::Sucrose::Meta::Class::Table' );
        $Table = DBICx::Sucrose::Table->new( schema_class => $caller, moniker => $moniker, class => $Table_class, class_meta => $Table_class_meta );
        $Table_class_meta->table( $Table );
        $Table->name( $table_name ) if $table_name;

        
        try {

            my @column;
            for my $token ( @_ ) {
                if ( ! ref $token ) {
                    $token = DBICx::Sucrose::Token->new( kind => 'name', value => $token );
                    $Table->column( @column ) if @column;
                    @column = ( $token );
                }
                unless ( blessed $token && $token->isa( 'DBICx::Sucrose::Token' ) ) {
                    croak "Invalid token ($token)";
                }
            }
            $Table->column( @column ) if @column;

        } catch {
            undef $Table;
            die $@;
        }
        
        _Table->register;
        undef $Table;
    }
}

sub column {
    return _Table->column( @_ );
}

sub unique {
}

sub commit {
}

################
# Relationship #
################

sub has_many {
}

sub belongs_to {
}

sub has_one {
}

#########
# Token #
#########

sub Type {
    my $value = shift;
    croak "Type requires a value" unless defined $value && length $value;
    return DBICx::Sucrose::Token->new( kind => 'type', value => $value );
}

for (qw/Integer Number Text Blog/) {
    my $type = $_;
    __PACKAGE__->meta->add_method( $type => sub {
        return DBICx::Sucrose::Token->new( kind => 'type', value => $type );
    } );
}
*Int = \&Integer;

sub NotNull {
    return DBICx::Sucrose::Token->new( kind => 'nullable', value => 0 );
}

sub Null {
    return DBICx::Sucrose::Token->new( kind => 'nullable', value => 1 );
}

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dbicx-sucrose at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBICx-Sucrose>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBICx::Sucrose


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBICx-Sucrose>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBICx-Sucrose>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBICx-Sucrose>

=item * Search CPAN

L<http://search.cpan.org/dist/DBICx-Sucrose/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of DBICx::Sucrose
