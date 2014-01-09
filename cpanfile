requires 'App::skryf::Plugin::Admin';
requires 'App::skryf::Util';
requires 'DDP';
requires 'DateTime';
requires 'List::Util';
requires 'Mango::BSON';
requires 'Method::Signatures';
requires 'Mojo::Base';
requires 'Mojo::JSON';
requires 'Test::Mojo';
requires 'Test::More';

on configure => sub {
    requires 'ExtUtils::MakeMaker', '6.30';
};
