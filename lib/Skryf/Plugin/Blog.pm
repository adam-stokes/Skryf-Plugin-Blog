package Skryf::Plugin::Blog;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::JSON;

use Skryf::Plugin::Blog::Model;
use Skryf::Util;

our $VERSION = '0.03';

###############################################################################
# Plugin Metadata
###############################################################################
has support_version => '>= 0.99_3';
has template_files => qw[dashboard index new edit detail];

###############################################################################
# Plugin Options
###############################################################################
has indexPath   => '/blog';
has postPath    => '/blog/:slug';
has feedPath    => '/blog/feeds/atom.xml';
has feedCatPath => '/blog/feeds/:category/atom.xml';

sub register {
    my ($self, $app) = @_;
    $app->helper(
        model => sub {
            my $self = shift;
            return Skryf::Plugin::Blog::Model->new(dbname => $self->config->{dbname});
        }
    );

    $app->routes->route($self->feedPath)->via('GET')->to(
        cb => sub {
            my $self  = shift;
            my $posts = $self->model->all;
            my $feed  = Skryf::Util->feed($self->config, $posts);

            $self->render(text => $feed->as_string, format => 'xml');
        }
    )->name('blog_get_feed');

    $app->routes->route($self->feedCatPath)->via('GET')->to(
        cb => sub {
            my $self     = shift;
            my $category = $self->param('category');
            my $posts    = $self->model->by_cat($category);
            my $feed     = Skryf::Util->feed($self->config, $posts);
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
    my $admin = $app->is_admin;
    my $auth_r = $app->routes->under($app->is_admin);
    if ($auth_r) {
        $auth_r->route('/admin/blog')->via('GET')->to(
            cb => sub {
                my $self = shift;
                $self->stash(postlist => $self->model->all);
                $self->render('/blog/dashboard');
            }
        )->name('admin_blog_dashboard');
        $auth_r->route('/admin/blog/new')->via(qw(GET POST))->to(
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
        $auth_r->route('/admin/blog/edit/:slug')->via('GET')->to(
            cb => sub {
                my $self = shift;
                my $slug = $self->param('slug');
                $self->stash(post => $self->model->get($slug));
                $self->render('blog/edit');
            }
        )->name('admin_blog_edit');
        $auth_r->route('/admin/blog/update')->via('POST')->to(
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
        $auth_r->route('/admin/blog/delete/:slug')->via('GET')->to(
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

    return;
}

1;
__END__

=head1 NAME

Skryf::Plugin::Blog - Skryf Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Blog');

  # Mojolicious::Lite
  plugin 'Blog';

  # Configuration
  plugins => {Blog => 1}

=head1 DESCRIPTION

L<Skryf::Plugin::Blog> is a L<Skryf> plugin.

=head1 PLUGIN META

=head2 support_version

Minimal Skryf version that supports this plugin.

=head2 template_files

Template files this plugin recognizes for rendered output.

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

L<Skryf::Plugin::Blog> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

    $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 ROUTES

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

=head1 RETURN VALUE

All routes that require viewing/editing of data will place any
accessible data within the applications B<stash>. This plugin provides
the following stash objects

=head2 post

  $c->stash(post => $post);
  <%= $post->{title} %>

A single blog post object

=head2 postlist

  $c->stash(postlist => $posts_array);
  <% for my $post ( @{$postlist} ) { %>
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
