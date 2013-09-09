# NAME

App::skryf::Plugin::Blog - Skryf Plugin

# SYNOPSIS

    # Mojolicious
    $self->plugin('Blog');

    # Mojolicious::Lite
    plugin 'Blog';

    # skryf.conf
    extra_modules => {Blog => 1}

# DESCRIPTION

[App::skryf::Plugin::Blog](http://search.cpan.org/perldoc?App::skryf::Plugin::Blog) is a [App::skryf](http://search.cpan.org/perldoc?App::skryf) plugin.

# OPTIONS

## indexPath

Blog index route

## postPath

Blog detail post path

## adminPathPrefix

Blog admin prefix route

## feedPath

Path to RSS feed

## feedCatPath

Path to categorized RSS feed

## namespace

Blog controller namespace.

# METHODS

[App::skryf::Plugin::Blog](http://search.cpan.org/perldoc?App::skryf::Plugin::Blog) inherits all methods from
[Mojolicious::Plugin](http://search.cpan.org/perldoc?Mojolicious::Plugin) and implements the following new ones.

## register

    $plugin->register(Mojolicious->new);

Register plugin in [Mojolicious](http://search.cpan.org/perldoc?Mojolicious) application.

# AUTHOR

Adam Stokes <adamjs@cpan.org>

# COPYRIGHT

Copyright 2013- Adam Stokes

# LICENSE

Licensed under the same terms as Perl.

# SEE ALSO

[App::skryf](http://search.cpan.org/perldoc?App::skryf), [Mojolicious](http://search.cpan.org/perldoc?Mojolicious), [Mojolicious::Guides](http://search.cpan.org/perldoc?Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).
