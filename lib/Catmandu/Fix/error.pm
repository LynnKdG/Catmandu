package Catmandu::Fix::error;

use Catmandu::Sane;

our $VERSION = '1.08';

use Moo;
use Catmandu::Util qw(is_value :data);
use namespace::clean;
use Catmandu::Fix::Has;

with 'Catmandu::Fix::Inlineable';

has message => (fix_arg => 1);

sub fix {
    my ($self, $data) = @_;
    my $msg = $self->message;
    if (looks_like_data_path($msg)) {
        my @messages = data_at($msg, $data);
        @messages || return $data;
        $msg = join "\n", grep { is_value($_) } @messages;
    }
    Catmandu::Error->throw($msg);
}

1;

__END__

=pod

=head1 NAME

Catmandu::Fix::error - die with an error message

=head1 SYNOPSIS

  unless exists(id)
    error('id missing!')
  end

  error($.errors.*)

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

