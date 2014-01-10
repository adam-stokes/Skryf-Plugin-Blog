package App::skryf::Plugin::Blog;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::JSON;

use App::skryf::Plugin::Blog::Model;
use App::skryf::Plugin::Admin;
use App::skryf::Util;

our $VERSION = '0.02';

# META
# This plugin provides an exposed RESTful interface
has plugin_rest => 0;

# API is public
has plugin_rest_public => 0;

# API prefix is /api/blog
has plugin_rest_prefix => '/blog';

# API version is
has plugin_rest_version => '1.0';

# Template files used
has template_files => qw[dashboard index new edit detail];

# OPTIONS
has indexPath   => '/blog';
has postPath    => '/blog/:slug';
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
            my $posts    = $self->model->by_cat($category);
            my $feed     = App::skryf::Util->feed($self->config, $posts);
            $self->render(text => $feed->as_string, format => 'xml');
        }
    )->name('blog_get_feed_by_cat');

    $app->routes->route($self->indexPath)->via('GET')->to(
        cb => sub {
            my $self = shift;
            $self->stash(postlist => $self->model->all);
            $self->render('blog/index');
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
            $post = $self->model->get($slug);
            if (!$post) {
                $app->log->debug('No post found for: ' . $slug);
                $post = {msg => 'No post found'};
            }
            $self->stash(post => $post);
            $self->render('blog/detail');
        }
    )->name('blog_get_post');

    # Administration section
    my $admin = App::skryf::Plugin::Admin->new(app => $app);
    my $auth_r = $app->routes->under($admin->is_admin);
    if ($auth_r) {
        $auth_r->route($admin->path_prefix . '/blog')->via('GET')->to(
            cb => sub {
                my $self = shift;
                $self->stash(postlist => $self->model->all);
                $self->render('/blog/dashboard');
            }
        )->name('admin_blog_dashboard');
        $auth_r->route($admin->path_prefix . '/blog/new')->via(qw(GET POST))->to(
            cb => sub {
                my $self   = shift;
                my $method = $self->req->method;
                if ($method eq "POST") {
                    my $title   = $self->param('title');
                    my $content = $self->param('content');
                    my $tags    = $self->param('tags');
                    $self->model->create($title, $content, $tags);
                    $self->redirect_to('admin_blog_dashboard');
                }
                else {
                    $self->render('blog/new');
                }
            }
        )->name('admin_blog_new');
        $auth_r->route($admin->path_prefix . '/blog/edit/:slug')->via('GET')->to(
            cb => sub {
                my $self = shift;
                my $slug = $self->param('slug');
                $self->stash(post => $self->model->get($slug));
                $self->render('blog/edit');
            }
        )->name('admin_blog_edit');
        $auth_r->route($admin->path_prefix . '/blog/update')->via('POST')->to(
            cb => sub {
                my $self = shift;
                my $slug = $self->param('slug');
                my $post = $self->model->get($slug);
                $post->{title}   = $self->param('title');
                $post->{content} = $self->param('content');
                $post->{tags}    = $self->param('tags');
                $self->model->save($post);
                $self->redirect_to(
                    $self->url_for(
                        'admin_blog_edit', {slug => $post->{slug}}
                    )
                );
            }
        )->name('admin_blog_update');
        $auth_r->route($admin->path_prefix . '/blog/delete/:slug')->via('GET')->to(
            cb => sub {
                my $self = shift;
                my $slug = $self->param('slug');
                if ($self->model->remove($slug)) {
                    $self->flash(message => 'Removed: ' . $slug);
                }
                else {
                    $self->flash(message => 'Failed to remove post.');
                }
                $self->redirect_to('admin_blog_dashboard');
            }
        )->name('admin_blog_delete');
    }

    # register menu item
    push @{$app->admin_menu},
      { menu => {
            name   => 'Blog',
            action => 'admin_blog_dashboard',
        }
      };
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

=head2 ROUTES

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

=head1 AUTHOR

Adam Stokes E<lt>adamjs@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Adam Stokes

=head1 LICENSE

Licensed under the same terms as Perl.

=head1 SEE ALSO

L<App::skryf>, L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
