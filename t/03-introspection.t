use strict;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More tests => 14;
use Test::Exception;
use HasClassAttribute;
use Child;

my $parent = 'HasClassAttribute';
my $child  = 'Child';

my $parent_meta = $parent->meta;
my $child_meta  = $child->meta;

ok $parent_meta->has_class_attribute('ObjectCount'), q{has_class_attribute('ObjectCount') returns true};

{
    my $parent_attr_meta = $parent_meta->get_class_attribute('ObjectCount')->meta;
    ok $parent_attr_meta->does_role('MouseX::ClassAttribute::Role::Meta::Attribute'),
        'get_class_attribute_list returns an object '.
        'which does the MouseX::ClassAttribute::Role::Meta::Attribute role';
}

my @class_attrs = qw(LazyAttribute ObjectCount ReadOnlyAttribute WeakAttribute);

is_deeply
    [ sort $parent_meta->get_class_attribute_list ],
    [ sort @class_attrs ],
    'HasClassAttribute get_class_attribute_list gets all class attributes';

is_deeply
    [ sort map { $_->name } $parent_meta->get_all_attributes ],
    [ 'instance_attribute' ],
    'HasClassAttribute get_all_attributes only finds instance_attribute attribute';

is_deeply
    [ sort map { $_->name } $parent_meta->get_all_class_attributes ],
    [ sort @class_attrs ],
    'HasClassAttribute get_all_class_attributes gets all class attributes';

is_deeply
    [ sort keys %{ $parent_meta->get_class_attribute_map } ],
    [ sort @class_attrs ],
    'HasClassAttribute get_class_attribute_map gets all class attributes';

is_deeply
    [ sort map { $_->name } $child_meta->get_all_class_attributes ],
    [ sort (@class_attrs, 'YetAnotherAttribute') ],
    'Child get_class_attribute_map gets all class attributes';

ok( ! Child->meta()->has_class_attribute('ObjectCount'),
    q{has_class_attribute('ObjectCount') returns false for Child} );

ok( Child->meta()->has_class_attribute('YetAnotherAttribute'),
    q{has_class_attribute('YetAnotherAttribute') returns true for Child} );

ok( Child->can('YetAnotherAttribute'),
    'Child has accessor for YetAnotherAttribute' );

ok( Child->meta()->has_class_attribute_value('YetAnotherAttribute'),
    'Child has class attribute value for YetAnotherAttribute' );

TODO: {
    local $TODO = "not implemented removing accessor";
Child->meta()->remove_class_attribute('YetAnotherAttribute');

ok( ! Child->meta()->has_class_attribute('YetAnotherAttribute'),
    q{... has_class_attribute('YetAnotherAttribute') returns false after remove_class_attribute} );

ok( ! Child->can('YetAnotherAttribute'),
    'accessor for YetAnotherAttribute has been removed' );

ok( ! Child->meta()->has_class_attribute_value('YetAnotherAttribute'),
    'Child does not have a class attribute value for YetAnotherAttribute' );
};
