#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

use Data::Dumper;

BEGIN {
    use_ok('Path::Router');
}

my $router = Path::Router->new;
isa_ok($router, 'Path::Router');

can_ok($router, 'add_route');
can_ok($router, 'match');
can_ok($router, 'uri_for');

# create some routes

$router->add_route('blog' => {
    controller => 'blog',
    action     => 'index',
});

$router->add_route('blog/:year/:month/:day' => {
    controller => 'blog',
    action     => 'show_date',
    year       => qr/\d\d\d\d/,
    month      => qr/\d\d?/,
    day        => qr/\d\d?/,        
});

$router->add_route('blog/:action/:id' => {
    controller => 'blog',
    id         => qr/\d+/
});

# add a catch all 
$router->add_route(':controller/:action/:id');

# create some tests

my %passing_tests = ( 
    # blog
    'blog' => {
        controller => 'blog',
        action     => 'index',
    },    
    # blog/:year/:month/:day
    'blog/2006/20/5' => {
        controller => 'blog',
        action     => 'show_date',
        year       => 2006,
        month      => 20,
        day        => 5,        
    },
    # blog/:year/:month/:day
    'blog/1920/1/50' => {
        controller => 'blog',
        action     => 'show_date',
        year       => 1920,
        month      => 1,
        day        => 50,        
    },    
    # blog/:action/:id
    'blog/edit/5' => {
        controller => 'blog',
        action     => 'edit',
        id         => 5
    },
    'blog/show/123' => {
        controller => 'blog',
        action     => 'show',
        id         => 123
    }, 
    'blog/some_crazy_long_winded_action_name/12356789101112131151' => {
        controller => 'blog',
        action     => 'some_crazy_long_winded_action_name',
        id         => '12356789101112131151',
    },    
    'blog/delete/5' => {
        controller => 'blog',
        action     => 'delete',
        id         => 5,
    },        
);

# test the roundtrip

foreach my $path (keys %passing_tests) {
    # the path generated from the hash
    # is the same as the path supplied
    is(
        $path, 
        $router->uri_for(%{$passing_tests{$path}}), 
        '... round-tripping the light fantasitc'
    );
    # the path supplied produces the
    # same match as the hash supplied 
    is_deeply(
        $router->match($path),
        $passing_tests{$path},
        '... dont call it a comeback, I been here for years'
    );    
}

1;



