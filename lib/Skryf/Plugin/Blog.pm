package Skryf::Plugin::Blog;

use Mojo::Base 'Mojolicious::Plugin';

use Skryf::Plugin::Blog::Model;
use Skryf::Util;

our $VERSION = '0.03';

###############################################################################
# Plugin Metadata
###############################################################################
has author                => 'Adam Stokes <adamjs@cpan.org>';
has upstream              => 'https://github.com/skryf/Skryf-Plugin-Blog';
has skryf_support_version => '>= 0.99_3';

sub register {
    my ($self, $app) = @_;
    $app->helper(
        model => sub {
            my $self = shift;
            return Skryf::Plugin::Blog::Model->new(
                dbname => $self->config->{dbname});
        }
    );

    $app->helper(
        blog_all => sub {
            my $self = shift;
            return Skryf::Util->json->decode($self->model->all);
        }
    );

    $app->helper(
        blog_one => sub {
            my $self = shift;
            my $slug = shift;
            return Skryf::Util->json->decode($self->model->get($slug))
              || undef;
        }
    );

    $app->helper(
        blog_feed => sub {
            my $self  = shift;
            my $posts = $self->model->all;
            my $feed  = Skryf::Util->feed($self->config, $posts);
            return $feed->as_string;
        }
    );

    $app->helper(
        blog_feed_by_cat => sub {
            my $self     = shift;
            my $category = shift;
            my $posts    = $self->model->by_cat($category);
            my $feed     = Skryf::Util->feed($self->config, $posts);
            return $feed->as_string;
        }
    );

###############################################################################
# Routes
###############################################################################
    $app->routes->route('/blog')->via('GET')->to(
        cb => sub {
            my $self = shift;
            $self->render(json => {postlist => $self->blog_all});
        }
    )->name('blog_index');
    $app->routes->route('/blog/:slug')->via('GET')->to(
        cb => sub {
            my $self = shift;
            my $slug = $self->param('slug');
            $self->render(json => {post => $self->blog_one($slug)});
        }
    )->name('blog_detail');
    $app->routes->route('/blog/feed')->via('GET')->to(
        cb => sub {
            my $self = shift;
            $self->render(xml => $self->blog_feed);
        }
    )->name('blog_feed');
    $app->routes->route('/blog/feed/:category')->via('GET')->to(
        cb => sub {
            my $self     = shift;
            my $category = $self->param('category');
            $self->render(xml => $self->blog_feed_by_cat($category));
        }
    )->name('blog_feed_category');
    return;
}

1;
__END__

=head1 NAME

Skryf::Plugin::Blog - Skryf Plugin

=head1 SYNOPSIS

  # In Skryf configuration
  plugins => {Blog => 1}

=head1 DESCRIPTION

L<Skryf::Plugin::Blog> is a L<Skryf> plugin.

=head1 PLUGIN META

=head2 author

Plugin Author

=head2 upstream

Upstream source URL

=head2 skryf_support_version

Minimal Skryf version that supports this plugin.

=head1 HELPERS

=head2 model

=head2 blog_all

=head2 blog_one

=head2 blog_feed

=head2 blog_feed_by_cat

=head1 METHODS

L<Skryf::Plugin::Blog> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

    $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 ROUTES

A list of current available routes:

    /blog                           GET       "blog_index"
    /blog/:slug                     GET       "blog_detail"
    /blog/feed/                     GET       "blog_feed"
    /blog/feed/:category/           GET       "blog_feed_category"

=head1 RETURN VALUE

Except for the RSS feeds these routes return JSON output of either a
single post or multiple posts. The top level keys associated with each
are described below.

=head2 post

  $c = Mojo::JSON->decode($ua->get('/blog/a-post-slug')->res->body);
  <%= $c->{post}->{title} %>

A single blog post object

=head2 postlist

  $c = Mojo::JSON->decode($ua->get('/blog')->res->body);
  <% for my $post ( @{$c->{postlist}} ) { %>
    <%= $post->{title} %>
  <% } %>

Multiple blog post objects.

=head1 AUTHOR

Adam Stokes E<lt>adamjs@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Adam Stokes

=head1 LICENSE

Licensed under the same terms as Perl.

=head1 SEE ALSO

L<Skryf>, L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
