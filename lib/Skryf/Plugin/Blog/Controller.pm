package Skryf::Plugin::Blog::Controller;

use Mojo::Base 'Mojolicious::Controller';
use Hash::Merge;
use DDP;

sub index {
    my $self = shift;
    $self->stash(postlist => $self->blog_all);
    $self->render('/blog/index');
}

sub detail {
    my $self = shift;
    my $slug = $self->param('slug');
    $self->stash(post => $self->blog_one($slug));
    $self->render('/blog/detail');
}

sub feed {
    my $self = shift;
    $self->render(text => $self->blog_feed, format => 'xml');
}

sub feed_by_cat {
    my $self     = shift;
    my $category = self->param('category');
    $self->render(
        text   => $self->blog_feed_by_cat($category),
        format => 'xml'
    );
}

sub admin_dashboard {
    my $self = shift;
    $self->stash(postlist => $self->blog_all);
    $self->render('/admin/blog/dashboard');
}

sub admin_edit {
    my $self = shift;
    my $slug = $self->param('slug');
    $self->stash(post => $self->blog_one($slug));
    $self->render('/admin/blog/edit');
}

sub admin_new {
    my $self = shift;
    if ($self->req->method eq "POST") {
        my $params = $self->req->params->to_hash;
        $self->blog_model->create($params);
        $self->flash(message => "Saved.");
        $self->redirect_to('admin_blog_dashboard');
    }
    else {
        $self->render('/admin/blog/new');
    }
}

sub admin_update {
    my $self      = shift;
    my $slug      = $self->param('slug');
    my $is_posted = $self->blog_one($slug);
    if ($is_posted) {
      my $merge = Hash::Merge->new('RIGHT_PRECEDENT');
        my $params = $self->req->params->to_hash;
        $self->blog_model->save($merge->merge($is_posted,$params));
        $self->flash(message => "Saved post!");
    }
    else {
        $self->flash(message => sprintf("Could not find post: %s", $slug));
        $self->redirect_to('admin_blog_dashboard');
    }
    $self->redirect_to($self->url_for('admin_blog_dashboard'));
}

sub admin_delete {
    my $self = shift;
    my $slug = $self->param('slug');
    $self->blog_model->remove($slug);
    $self->flash(message => sprintf("Post: %s deleted.", $slug));
    $self->redirect_to($self->url_for('admin_blog_dashboard'));
}


1;
