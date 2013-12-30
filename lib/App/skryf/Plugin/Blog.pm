package App::skryf::Plugin::Blog;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::JSON;

use App::skryf::Plugin::Blog::Model;
use App::skryf::Plugin::Admin;
use App::skryf::Util;

use DDP;

# VERSION

has indexPath   => '/blog/get_posts';
has postPath    => '/blog/get_post/:slug';
has feedPath    => '/blog/feeds/atom.xml';
has feedCatPath => '/blog/feeds/:category/atom.xml';

sub register {
    my ($self, $app) = @_;
    $app->helper(
        model => sub {
            my $self = shift;
            return App::skryf::Plugin::Blog::Model->new;
        }
    );

    $app->routes->route($self->feedPath)->via('GET')->to(
        cb => sub {
            my $self  = shift;
            my $posts = $self->model->all;
            my $feed  = App::skryf::Util->feed($self->config, $posts);

            $self->render(text => $feed->as_string, format => 'xml');
        }
    )->name('blog_get_feed');

    $app->routes->route($self->feedCatPath)->via('GET')->to(
        cb => sub {
            my $self     = shift;
            my $category = $self->param('category');
            my $posts    = $self->app->model->by_cat($category);
            my $feed     = App::skryf::Util->feed($self->config, $posts);
            $self->render(text => $feed->as_string, format => 'xml');
        }
    )->name('blog_get_feed_by_cat');

    $app->routes->route($self->indexPath)->via('GET')->to(
        cb => sub {
            my $self = shift;
            $self->render(json => $self->app->model->all);
        }
    )->name('blog_get_posts');

    $app->routes->route($self->postPath)->via('GET')->to(
        cb => sub {
            my $self = shift;
            my $post = undef;
            my $slug = $self->param('slug');
            unless ($slug =~ /^[A-Za-z0-9_-]+$/) {
                $post = {msg => 'Invalid post'};
            }
            $post = $self->app->model->get($slug);
            if (!$post) {
                $self->app->log->debug('No post found for: ' . $slug);
                $post = {msg => 'No post found'};
            }

            $self->render(json => $post);
        }
    )->name('blog_get_post');

    # Administration section
    my $admin = App::skryf::Plugin::Admin->new(app => $app);
    if ($admin->is_admin) {
        $admin->auth_r->route('blog/dashboard')->via('GET')->to(
            cb => sub {
                my $self = shift;
                $self->render(json => {dashboard => 'admin dashboard'});
            }
        )->name('admin_blog_dashboard');
    }
    return;
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
