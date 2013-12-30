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

[App::skryf::Plugin::Blog](https://metacpan.org/pod/App::skryf::Plugin::Blog) is a [App::skryf](https://metacpan.org/pod/App::skryf) plugin.

# OPTIONS

These are RESTful calls that return JSON or a proper RSS feed if integrating with aggregators.

## indexPath

Returns json output of all blog posts

## postPath

Returns json output of a blog detail

## feedPath

Returns XML formatted RSS feed

## feedCatPath

Returns XML formatted categorized RSS feed

# METHODS

[App::skryf::Plugin::Blog](https://metacpan.org/pod/App::skryf::Plugin::Blog) inherits all methods from
[Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin) and implements the following new ones.

## register

    $plugin->register(Mojolicious->new);

Register plugin in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

# AUTHOR

Adam Stokes <adamjs@cpan.org>

# COPYRIGHT

Copyright 2013- Adam Stokes

# LICENSE

Licensed under the same terms as Perl.

# SEE ALSO

[App::skryf](https://metacpan.org/pod/App::skryf), [Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).
