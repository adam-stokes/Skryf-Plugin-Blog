package App::skryf::Plugin::Blog;

use Mojo::Base 'Mojolicious::Plugin';
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use DDP;

use App::skryf::Plugin::Blog::Controller;

our $VERSION = '0.02';

has indexPath       => '/post/';
has postPath        => '/post/:slug';
has feedPath        => '/post/feeds/atom.xml';
has feedCatPath     => '/post/feeds/:category/atom.xml';
has namespace       => 'App::skryf::Plugin::Blog::Controller';

sub register {
    my ($self, $app, $config) = @_;

    $app->routes->route($self->feedPath)->via('GET')->to(
        namespace => $self->namespace,
        action    => 'blog_feeds',
    )->name('blog_feeds');

    $app->routes->route($self->feedCatPath)->via('GET')->to(
        namespace => $self->namespace,
        action    => 'blog_feeds_by_cat',
    )->name('blog_cat_feeds');

    $app->routes->route($self->indexPath)->via('GET')->to(
        namespace => $self->namespace,
        action    => 'blog_index',
    )->name('blog_index');

    $app->routes->route($self->postPath)->via('GET')->to(
        namespace => $self->namespace,
        action    => 'blog_detail',
    )->name('blog_detail');

    # Admin auth
    my $auth_r = $app->routes->under(
        sub {
            my $self = shift;
            return $self->session('user') || !$self->redirect_to('login');
        }
    );

    push @{$app->frontend_menu},
      { menu => {
            name   => 'Archives',
            action => 'blog_index'
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

Blog index route

=head2 postPath

Blog detail post path

=head2 adminPathPrefix

Blog admin prefix route

=head2 feedPath

Path to RSS feed

=head2 feedCatPath

Path to categorized RSS feed

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
