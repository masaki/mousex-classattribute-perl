package MouseX::ClassAttribute::Role::Meta::Attribute;

use Mouse::Role;
use Mouse::Util::TypeConstraints;
use MouseX::ClassAttribute::Meta::Method::Accessor;

around 'create' => sub {
    shift;
    my ($self, $class, $name, %args) = @_;

    $args{name} = $name;
    $args{associated_class} = $class;

    %args = $self->canonicalize_args($name, %args);
    $self->validate_args($name, \%args);

    $args{should_coerce} = delete $args{coerce}
        if exists $args{coerce};

    if (exists $args{isa}) {
        confess "Got isa => $args{isa}, but Mouse does not yet support parameterized types for containers other than ArrayRef and HashRef (rt.cpan.org #39795)"
            if $args{isa} =~ /^([^\[]+)\[.+\]$/ &&
               $1 ne 'ArrayRef' &&
               $1 ne 'HashRef'  &&
               $1 ne 'Maybe'
        ;

        my $type_constraint = delete $args{isa};
        $args{type_constraint}= Mouse::Util::TypeConstraints::find_or_create_isa_type_constraint($type_constraint);
    }

    my $attribute = $self->new($name, %args);

    # XXX: use "add_class_attribute" instead of "add_attribute"
    $class->add_class_attribute($attribute);

    # install an accessor
    if ($attribute->_is_metadata eq 'rw' || $attribute->_is_metadata eq 'ro') {
        # XXX: use "MouseX::ClassAttribute::Meta::Method::Accessor" instead of "Mouse::Meta::Method::Accessor"
        my $code = MouseX::ClassAttribute::Meta::Method::Accessor->generate_accessor_method_inline($attribute);
        $class->add_method($name => $code);
    }

    for my $method (qw/predicate clearer/) {
        my $predicate = "has_$method";
        if ($attribute->$predicate) {
            my $generator = "generate_$method";
            my $coderef = $attribute->$generator;
            $class->add_method($attribute->$method => $coderef);
        }
    }

    if ($attribute->has_handles) {
        my $method_map = $attribute->generate_handles;
        for my $method_name (keys %$method_map) {
            $class->add_method($method_name => $method_map->{$method_name});
        }
    }

    return $attribute;
};

no Mouse::Role;
1;

=head1 NAME

MooseX::ClassAttribute::Role::Meta::Attribute - An attribute role for classes with class attributes

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
