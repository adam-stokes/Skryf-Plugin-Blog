# NAME

Skryf::Plugin::Blog - Skryf Plugin

# SYNOPSIS

    # In Skryf configuration
    plugins => {Blog => 1}

# DESCRIPTION

[Skryf::Plugin::Blog](https://metacpan.org/pod/Skryf::Plugin::Blog) is a [Skryf](https://metacpan.org/pod/Skryf) plugin.

# HELPERS

## model

## blog\_all

## blog\_one

## blog\_feed

## blog\_feed\_by\_cat

# METHODS

[Skryf::Plugin::Blog](https://metacpan.org/pod/Skryf::Plugin::Blog) inherits all methods from
[Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin) and implements the following new ones.

## register

    $plugin->register(Mojolicious->new);

Register plugin in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

# ROUTES

A list of current available routes:

    /blog                        *     "blog_index"
    /blog/:slug                  *     "blog_detail"
    /blog/feed                   *     "blog_feed"
    /blog/feed/:category         *     "blog_feed_by_cat"
    /                            *
      +/admin/blog               *     "admin_blog_dashboard"
      +/admin/blog/edit/:slug    *     "admin_blog_edit"
      +/admin/blog/new           *     "admin_blog_new"
      +/admin/blog/update/:slug  POST  "admin_blog_update"
      +/admin/blog/delete/:slug  *     "admin_blog_delete"

# RETURN VALUE

The GET'able routes return either a single post or multiple post objects. They are described below:

## post

    $self->stash(post => $self->blog_one($slug));
    <%= $post->{title} %>

A single blog post object

## postlist

    $self->stash(postlist => $self->blog_all);
    <% for my $post ( @{$postlist} ) { %>
      <%= $post->{title} %>
    <% } %>

Multiple blog post objects.

# AUTHOR

Adam Stokes <adamjs@cpan.org>

# COPYRIGHT

Copyright 2013- Adam Stokes

# LICENSE

Licensed under the same terms as Perl.

# SEE ALSO

[Skryf](https://metacpan.org/pod/Skryf), [Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).
