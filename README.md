# NAME

Skryf::Plugin::Blog - Skryf Plugin

# SYNOPSIS

    # In Skryf configuration
    plugins => {Blog => 1}

# DESCRIPTION

[Skryf::Plugin::Blog](https://metacpan.org/pod/Skryf::Plugin::Blog) is a [Skryf](https://metacpan.org/pod/Skryf) plugin.

# PLUGIN META

## author

Plugin Author

## upstream

Upstream source URL

## skryf\_support\_version

Minimal Skryf version that supports this plugin.

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

    /blog                           GET       "blog_index"
    /blog/:slug                     GET       "blog_detail"
    /blog/feed/                     GET       "blog_feed"
    /blog/feed/:category/           GET       "blog_feed_category"

# RETURN VALUE

Except for the RSS feeds these routes return JSON output of either a
single post or multiple posts. The top level keys associated with each
are described below.

## post

    $c = Mojo::JSON->decode($ua->get('/blog/')->res->body);
    <%= $c->{post}->{title} %>

A single blog post object

## postlist

    $c = Mojo::JSON->decode($ua->get('/blog/a-post-slug')->res->body);
    <% for my $post ( @{$c->{postlist}} ) { %>
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
