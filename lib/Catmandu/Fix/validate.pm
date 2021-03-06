package Catmandu::Fix::validate;

use Catmandu::Sane;

our $VERSION = '1.07';

use Moo;
use Catmandu::Util qw(require_package);
use namespace::clean;
use Catmandu::Fix::Has;

has path           => (fix_arg => 1);
has name           => (fix_arg => 1);
has error_field    => (fix_opt => 1, default => 'errors');
has validator_opts => (fix_opt => 'collect');
has validator      => (is      => 'lazy', init_arg => undef);

with 'Catmandu::Fix::SimpleGetValue';

sub emit_value {
    my ($self, $var, $fixer) = @_;
    my $validator_var = $fixer->capture($self->validator);
    my $errors_var    = $fixer->generate_var;
    my $error_field
        = $self->error_field ? $fixer->split_path($self->error_field) : undef;

    "unless (${validator_var}->is_valid(${var})) {"
        . $fixer->emit_declare_vars($errors_var)
        . "${errors_var} = ${validator_var}->last_errors;"
        . $fixer->emit_create_path(
        $fixer->var,
        $error_field,
        sub {
            my $var = shift;
            "${var} = ${errors_var}";
        }
        ) . "}";
}

sub _build_validator {
    my ($self) = @_;
    require_package($self->name, 'Catmandu::Validator')
        ->new($self->validator_opts);
}

1;

__END__

=pod

=head1 NAME

Catmandu::Fix::validate - validate data and keep errors

=head1 SYNOPSIS

   # Check author field against a JSON Schema
   validate('author', JSONSchema, schema: 'my/schema.json')
   if exists(errors)
      ... # do something
   end

   # Check item against a custom validator, store in errors in 'warnings'
   validate('author', MyValidatorClass, error_field: warnings)

=head1 DESCRIPTION

This L<Catmandu::Fix> validates data with a L<Catmandu::Validator> and stores
errors in field C<errors> for further inspection.

=head1 CONFIGURATION

=over

=item error_field

Path where to store errors. Set to C<errors> by default.

=back

Additional options are passed to the validator.

=head1 SEE ALSO

L<Catmandu::Fix::Condition::valid>

=cut
