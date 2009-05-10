#!perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'DBICx::Sucrose' );
}

diag( "Testing DBICx::Sucrose $DBICx::Sucrose::VERSION, Perl $], $^X" );
