package MouseX::ClassAttribute::Role::Meta::Class;

use Mouse::Role;
use Mouse::Util;
use Mouse::Meta::Class;
use MouseX::AttributeHelpers;
use MouseX::ClassAttribute::Role::Meta::Attribute;

has '_class_attribute_map' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef',
    provides  => {
        set    => '_add_class_attribute',
        exists => 'has_class_attribute',
        get    => 'get_class_attribute',
        delete => 'remove_class_attribute',
        keys   => 'get_class_attribute_list',
    },
    lazy      => 1,
    default   => sub { {} },
);

has '_class_attribute_values' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef',
    provides  => {
        get    => 'get_class_attribute_value',
        set    => 'set_class_attribute_value',
        exists => 'has_class_attribute_value',
        delete => 'clear_class_attribute_value',
    },
    lazy      => 1,
    default   => sub { $_[0]->_class_attribute_values_hashref },
);

sub get_class_attribute_map { $_[0]->_class_attribute_map }

sub _class_attribute_var_name { $_[0]->name . '::__ClassAttributeValues' }

sub _class_attribute_values_hashref {
    no strict 'refs';
    return \%{ $_[0]->_class_attribute_var_name };
}

sub add_class_attribute {
    my $self = shift;

    if (blessed $_[0]) {
        my $attr = shift @_;

        $self->_add_class_attribute($attr->name, $attr);

        if ($attr->has_builder || $attr->has_default) {
            unless ($attr->is_lazy) {
                my $default = $attr->default;
                my $builder = $attr->builder;

                my $value = do {
                    if ($attr->has_builder) {
                        $self->$builder;
                    }
                    elsif (ref($default) eq 'CODE') {
                        $default->($self);
                    }
                    elsif (!defined($default)) {
                        undef;
                    }
                    else {
                        $default;
                    }
                };

                $self->set_class_attribute_value($attr->name, $value);
            }
        }

        return $attr;
    }
    else {
        my ($names, %options) = @_;
        $names = [$names] if !ref($names);

        my $base = exists $options{metaclass}
            ? Mouse::Util::resolve_metaclass_alias('Attribute', delete $options{metaclass})
            : $self->attribute_metaclass;

        my $metaclass = Mouse::Meta::Class->create_anon_class(superclasses => [$base])->name;
        Mouse::Util::apply_all_roles($metaclass, 'MouseX::ClassAttribute::Role::Meta::Attribute');

        for my $name (@$names) {
            if ($name =~ s/^\+//) {
                my $attr = $self->find_class_attribute_by_name($name)
                    or confess "Could not find an attribute by the name of '$name' to inherit from";

                $attr->clone_parent($self, $name, %options);
            }
            else {
                $metaclass->create($self, $name, %options);
            }
        }
    }
}

sub get_all_class_attributes {
    my $self = shift;

    my %attrs = map {
        my $meta = Mouse::Meta::Class->initialize($_);
        $meta->can('get_class_attribute_map') ? %{ $meta->get_class_attribute_map } : ()
    } reverse $self->linearized_isa;

    return values %attrs;
}

sub find_class_attribute_by_name {
    my ($self, $name) = @_;

    for my $class ($self->linearized_isa) {
        my $meta = Mouse::Meta::Class->initialize($class);
        return $meta->get_class_attribute($name)
            if $meta->can('has_class_attribute') && $meta->has_class_attribute($name);
    }

    return;
}

no Mouse::Role;
1;

=head1 NAME

MooseX::ClassAttribute::Role::Meta::Class - A metaclass role for classes with class attributes

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
