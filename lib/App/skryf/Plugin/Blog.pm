package App::skryf::Plugin::Blog;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::JSON;

use App::skryf::Plugin::Blog::Model;
use App::skryf::Util;

# debug
use DDP;

# VERSION

has indexPath   => '/blog/get_posts';
has postPath    => '/blog/get_post/:slug';
has feedPath    => '/blog/feeds/atom.xml';
has feedCatPath => '/blog/feeds/:category/atom.xml';
has json        => sub { my $self = shift; Mojo::JSON->new; };
has model       => sub { my $self = shift; App::skryf::Plugin::Blog::Model->new; };

sub register {
    my ($self, $app) = @_;

    $app->routes->route($self->feedPath)->via('GET')->to(
        cb => sub {
            my $self = shift;
            $self->render(text => \&_blog_feeds, format => 'xml');
        }
    )->name('blog_get_feed');

    $app->routes->route($self->feedCatPath)->via('GET')->to(
        cb => sub {
            my $self = shift;
            $self->render(text => \&_blog_feeds_by_cat, format => 'xml');
        }
    )->name('blog_get_feed_by_cat');

    $app->routes->route($self->indexPath)->via('GET')->to(
        cb => sub {
            my $self = shift;
            $self->render(json => \&_blog_get_posts);
        }
    )->name('blog_get_posts');

    $app->routes->route($self->postPath)->via('GET')->to(
        cb => sub {
            my $self = shift;
            $self->render(json => \&_blog_get_post);
        }
    )->name('blog_get_post');

    return;
}

sub _blog_get_posts {
  my $self = shift;
  return $self->model->all;
}

sub _blog_get_post {
    my $self = shift;
    my $slug = $self->param('slug');
    unless ($slug =~ /^[A-Za-z0-9_-]+$/) {
        return {msg => 'Invalid post name!'};
    }
    my $post = $self->model->get($slug);
    unless ($post) {
        return {msg => 'No post found!'};
    }
    return $post;
}

sub _blog_feeds_by_cat {
  my $self = shift;
    my $category = $self->param('category');
    my $posts    = $self->model->by_cat($category);
    my $feed     = App::skryf::Util->feed($self->config, $posts);
    return $feed->as_string;
  }

sub _blog_feeds {
  my $self = shift;
    my $posts = $self->model->all;
    my $feed  = App::skryf::Util->feed($self->config, $posts);
    return $feed->as_string;
}

1;
__END__

=head1 NAME

App::skryf::Plugin::Blog - Skryf Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Blog');

  # Mojolicious::Lite
  plugin 'Blog';

  # skryf.conf
  extra_modules => {Blog => 1}

=head1 DESCRIPTION

L<App::skryf::Plugin::Blog> is a L<App::skryf> plugin.

=head1 OPTIONS

These are RESTful calls that return JSON or a proper RSS feed if integrating with aggregators.

=head2 indexPath

Returns json output of all blog posts

=head2 postPath

Returns json output of a blog detail

=head2 feedPath

Returns XML formatted RSS feed

=head2 feedCatPath

Returns XML formatted categorized RSS feed

=head2 namespace

Blog controller namespace.

=head1 METHODS

L<App::skryf::Plugin::Blog> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 AUTHOR

Adam Stokes E<lt>adamjs@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Adam Stokes

=head1 LICENSE

Licensed under the same terms as Perl.

=head1 SEE ALSO

L<App::skryf>, L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
