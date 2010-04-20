#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

package t::Schema;

use DBICx::Sucrose;

#table( 'Artist' => sub {

#    column 'name' => Text, NotNull;
#    column 'age' => Integer, Null;

#} );

#table( 'Cd' => sub {

#    column 'title' => Text, NotNull;
#    column 'SKU' => Type('CustomSKUType'), NotNull;

#} );

no DBICx::Sucrose;

package main;

ok( 1 );


1;
