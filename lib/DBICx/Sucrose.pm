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

use Moose ();
use DBICx::Sucrose::Carp;

use DBICx::Sucrose::Table;
use DBICx::Sucrose::Meta::Class::Table;

use Moose::Exporter;
use Class::MOP;
use DBIx::Class();


our ($Table);

Moose::Exporter->setup_import_methods(
    with_caller => [qw/ table /],
    as_is => [qw/ load column unique commit has_many belongs_to has_one /],
    also => [qw/ Moose /],
);
#    ( with_caller => [qw( has_table has_policy has_one has_many transform )],
#      as_is       => [qw( inflate deflate handles )],
#      also        => 'Moose'
#    );

sub init_meta {
    shift;

    return Moose->init_meta( @_, base_class => 'DBIx::Class::Schema' );
}

sub _Table() {
    return $Table or croak "No table \"in scope\"!";
}

sub table {
    my $caller = shift;
    if ($Table) {
        _Table->table( @_ );
    }
    else {
        my $moniker = shift;
        my $name;
        if (@_) {
            $name = shift;
        }

        my $Table_class = join '::', $caller, 'Result', $moniker;
        my $Table_class_meta = Moose->init_meta( for_class => $Table_class, base_class => 'DBIx::Class', metaclass => 'DBICx::Sucrose::Meta::Class::Table' );
        $Table = DBICx::Sucrose::Table->new( schema_class => $caller, moniker => $moniker, class => $Table_class, class_meta => $Table_class_meta );
        $Table_class_meta->table( $Table );
        $Table->table( $name ) if $name;
        my $code = shift;
        if ($code) {
            eval {
                $code->();
            };
            if ($@) {
                undef $Table;
                die $@;
            }
        }
        _Table->register;
        undef $Table;
    }
}

sub load {
    return _Table->load( @_ );
}

sub column {
    return _Table->column( @_ );
}

sub unique {
}

sub commit {
}

sub has_many {
}

sub belongs_to {
}

sub has_one {
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
