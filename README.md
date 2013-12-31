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

## ROUTES

A list of current available routes:

    /blog/feeds/atom.xml            GET       "blog_get_feed"
    /blog/feeds/:category/atom.xml  GET       "blog_get_feed_by_cat"
    /blog                           GET       "blog_get_posts"
    /blog/:slug                     GET       "blog_get_post"
    /                               *
    +/admin/blog                    GET       "admin_blog_dashboard"
    +/admin/blog/new                GET,POST  "admin_blog_new"
    +/admin/blog/edit/:slug         GET       "admin_blog_edit"
    +/admin/blog/update             POST      "admin_blog_update"
    +/admin/blog/delete/:slug       GET       "admin_blog_delete"

# AUTHOR

Adam Stokes <adamjs@cpan.org>

# COPYRIGHT

Copyright 2013- Adam Stokes

# LICENSE

Licensed under the same terms as Perl.

# SEE ALSO

[App::skryf](https://metacpan.org/pod/App::skryf), [Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).
