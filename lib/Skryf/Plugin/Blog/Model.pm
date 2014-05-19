package Skryf::Plugin::Blog::Model;

# ABSTRACT: Blog Model

use Skryf::Util;
use DateTime;

use Moo;
use namespace::clean;


sub this_year {
    my ($self, $limit) = @_;
    $limit = 5 unless $limit;
    my $year = DateTime->now->year;
    $self->q->find({created => qr/$year/})->sort({created => -1})
      ->limit($limit)->all;
}

sub by_year {
    my ($self, $year, $limit) = @_;
    $year = DateTime->now->year unless $year;
    $limit = -1 unless $limit;
    $self->q->find({created => qr/$year/})->sort({created => -1})
      ->limit($limit)->all;
}

sub create {
    my ($self, $items) = @_;
    $items->{public} = 0 unless $items->{public};
    my $_created = DateTime->now unless $items->{created};
    $items->{created} = $_created->strftime('%Y-%m-%dT%H:%M:%SZ');
    $items->{slug}    = Skryf::Util->slugify($items->{title});
    $items->{html}    = Skryf::Util->convert($items->{content});
    $self->q->insert($items);
}

sub save {
    my ($self, $post) = @_;
    $post->{slug} = Skryf::Util->slugify($post->{title});
    $post->{html} = Skryf::Util->convert($post->{content});
    my $lt = DateTime->now;
    $post->{modified} = $lt->strftime('%Y-%m-%dT%H:%M:%SZ');
    $self->q->save($post);
}

sub by_cat {
    my ($self, $category) = @_;
    my $_filtered = [];
    foreach (@{$self->all}) {
        if ((my $found = $_->{tags}) =~ /$category/) {
            push @{$_filtered}, $_;
        }
    }
    return $_filtered;
}

1;
__END__

=head1 DESCRIPTION

Post model

=head1 METHODS

=head2 B<posts>

Posts collection

=head2 B<create>

Accepts a hash of items to be inserted into the Blog collection.

=head3 B<Required keys that need to exist in the hash>

=head4 content

=head4 tags

=head4 title

=cut
