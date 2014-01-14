package Skryf::Plugin::Blog;

use Mojo::Base 'Mojolicious::Plugin';

use Skryf::Plugin::Blog::Model;
use Skryf::Util;

our $VERSION = '0.05';

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
            return $self->model->all || undef;
        }
    );

    $app->helper(
        blog_one => sub {
            my $self = shift;
            my $slug = shift;
            return $self->model->get($slug)
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
    # Add Blog/Controller.pm to our namespace
    push @{$app->routes->namespaces}, 'Skryf::Plugin::Blog';
    $app->routes->any('/blog')->to('controller#index')->name('blog_index');
    $app->routes->any('/blog/:slug')->to('controller#detail')
      ->name('blog_detail');
    $app->routes->any('/blog/feed')->to('controller#feed')->name('blog_feed');
    $app->routes->any('/blog/feed/:category')->to('controller#feed_by_cat')
      ->name('blog_feed_by_cat');

    # Admin hooks
    my $if_admin = $app->routes->under(
        sub {
            my $self = shift;
            return $self->auth_fail unless $self->is_admin;
        }
    );

    $if_admin->any('/admin/blog')->to('controller#admin_dashboard')
      ->name('admin_blog_dashboard');
    $if_admin->any('/admin/blog/edit/:slug')->to('controller#admin_edit')
      ->name('admin_blog_edit');
    $if_admin->any('/admin/blog/new')->to('controller#admin_new')
      ->name('admin_blog_new');
    $if_admin->post('/admin/blog/update/:slug')
      ->to('controller#admin_update')->name('admin_blog_update');
    $if_admin->any('/admin/blog/delete/:slug')->to('controller#admin_delete')
      ->name('admin_blog_delete');
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

=head1 RETURN VALUE

The GET'able routes return either a single post or multiple post objects. They are described below:

=head2 post

  $self->stash(post => $self->blog_one($slug));
  <%= $post->{title} %>

A single blog post object

=head2 postlist

  $self->stash(postlist => $self->blog_all);
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
