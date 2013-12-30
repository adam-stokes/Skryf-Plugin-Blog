#!/usr/bin/env perl

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;

use FindBin;
use lib "$FindBin::Bin../../lib";
use DDP;

plan skip_all => 'set TEST_ONLINE to enable this test'
  unless $ENV{TEST_ONLINE};

diag("Testing REST posts");
my $t = Test::Mojo->new('App::skryf');

my $json_out = $t->ua->get('/blog/get_posts');
p $json_out->res->body;
$t->get_ok('/blog/get_posts')->status_is(200)->content_type_is('application/json', 'its json');

done_testing();
