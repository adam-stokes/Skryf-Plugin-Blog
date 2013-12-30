package App::skryf::Plugin::Blog::Controller;

# VERSION

use Mojo::Base 'Mojolicious::Controller';
use Method::Signatures;
use App::skryf::Plugin::Blog::Model;
use XML::Atom::SimpleFeed;
use DateTime::Format::RFC3339;
use Encode;

has model => App::skryf::Plugin::Blog::Model->new;

method blog_index {
    my $posts = $self->model->all;
    $self->render(json => $posts);
}

method blog_detail {
    my $slug = $self->param('slug');
    unless ($slug =~ /^[A-Za-z0-9_-]+$/) {
        $self->render(json => 'Invalid post name!', status => 404);
        return;
    }
    my $post  = $self->model->get($slug);
    unless ($post) {
        $self->render(json => 'No post found!', status => $post);
    }
    $self->render(json => $post);
}

method blog_feeds_by_cat {
    my $category = $self->param('category');
    my $posts    = $self->model->by_cat($category);
    my $feed     = App::skryf::Util->feed($self->config, $posts);
    $self->render(text => $feed->as_string, format => 'xml');
}

method blog_feeds {
    my $posts = $self->model->all;
    my $feed  = App::skryf::Util->feed($self->config, $posts);
    $self->render(text => $feed->as_string, format => 'xml');
}

1;
__END__

=head1 NAME

App::skryf::Plugin::Blog::Controller - blog plugin controller

=head1 DESCRIPTION

Simple controller class for handling listing, viewing, and administering
blog posts.

=head1 CONTROLLERS

=head2 B<blog_index>

=head2 B<blog_archive>

=head2 B<blog_detail>

=cut
