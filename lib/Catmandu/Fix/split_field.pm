package Catmandu::Fix::split_field;

use Catmandu::Sane;
use Catmandu::Util qw(:is data_at);
use Moo;

has path      => (is => 'ro', required => 1);
has key       => (is => 'ro', required => 1);
has split_char => (is => 'ro', required => 1);

around BUILDARGS => sub {
    my ($orig, $class, $path, $split_char) = @_;
    $path = [split /\./, $path];
    my $key = pop @$path;
    $orig->($class, path => $path, key => $key, split_char => $split_char // qr'\s+');
};

sub fix {
    my ($self, $data) = @_;

    my $key = $self->key;
    my $split_char = $self->split_char;
    my @matches = grep ref, data_at($self->path, $data);
    for my $match (@matches) {
        if (is_array_ref($match)) {
            is_integer($key) || next;
            my $val = $match->{$key};
            $match->[$key] = [split $split_char, $val] if is_string($val);
        } else {
            my $val = $match->{$key};
            $match->{$key} = [split $split_char, $val] if is_string($val);
        }
    }

    $data;
}

=head1 NAME

Catmandu::Fix::split_field - split a string value in a field into an ARRAY

=head1 SYNOPSIS

   # Split the 'foo' value into an array. E.g. foo => '1:2:3'
   split_field('foo',':'); # foo => [1,2,3]

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

1;
