#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

package t::Schema;

use DBICx::Sucrose;

table( 'Xyzzy' => 'xyzzy', sub {

    column( 'apple' );

} );


package main;

ok( 1 );


1;
