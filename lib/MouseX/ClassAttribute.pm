package MouseX::ClassAttribute;

use 5.008_001;
use strict;
use warnings;
use base 'Exporter';
use Mouse::Util::MetaRole;
use MouseX::ClassAttribute::Role::Meta::Class;

our $VERSION = '0.002';

our @EXPORT = qw(class_has);

sub class_has {
    my ($name, %opts) = @_;
    my $meta = Mouse::Meta::Class->initialize(caller);
    $meta->add_class_attribute($_, %opts) for (ref $name eq 'ARRAY' ? @$name : ($name));
}

sub import {
    my $class = shift;
    $class->export_to_level(1);

    my $for_class = caller;
    Mouse::Util::MetaRole::apply_metaclass_roles(
        for_class       => $for_class,
        metaclass_roles => ['MouseX::ClassAttribute::Role::Meta::Class'],
    );
}

sub unimport {
    my $caller = caller;

    no strict 'refs';
    for my $keyword (@EXPORT) {
        delete ${ $caller . '::' }{$keyword};
    }
}

1;
__END__

=head1 NAME

MouseX::ClassAttribute -

=head1 SYNOPSIS

  use MouseX::ClassAttribute;

=head1 DESCRIPTION

MouseX::ClassAttribute is

=head1 AUTHOR

taiyoh E<lt>sun.basix@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
