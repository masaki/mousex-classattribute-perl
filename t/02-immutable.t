use strict;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More tests => 16;
use Test::Exception;
use HasClassAttribute;
use Child;

# make_immutable
HasClassAttribute->meta->make_immutable;
Child->meta->make_immutable;

my $class = 'HasClassAttribute';
is $class->ObjectCount => 0, 'ObjectCount() is 0';

{
    my $obj = $class->new;
    is $obj->instance_attribute => 5, 'instance_attribute is 5 - object attribute works as expected';
    is $class->ObjectCount => 1, 'ObjectCount() is 1';
}

{
    my $obj = $class->new(instance_attribute => 10);
    is $obj->instance_attribute => 10, 'instance_attribute is 10 - object attribute can be set via constructor';
    is $class->ObjectCount => 2, 'ObjectCount() is 2';
    is $obj->ObjectCount => 2, 'ObjectCount() is 2 - can call class attribute accessor on object';
}

{
    my $obj = $class->new(ObjectCount => 20);
    is $obj->ObjectCount => 3, 'class attributes passed to the constructor do not get set in the object';
    is $class->ObjectCount => 3, 'class attributes are not affected by constructor params';
}

{
    my $object = bless {}, 'Thing';
    $class->WeakAttribute($object);

    ok defined $class->WeakAttribute, 'weak class attributes are weak, defined';
    undef $object;
    ok !defined $class->WeakAttribute, 'weak class attributes are weak, destory';
}

is $HasClassAttribute::Lazy => 0, '$HasClassAttribute::Lazy is 0';
is $class->LazyAttribute => 1, 'HasClassAttribute->LazyAttribute() is 1';
is $HasClassAttribute::Lazy => 1, '$HasClassAttribute::Lazy is 1 after calling LazyAttribute';

throws_ok { $class->ReadOnlyAttribute(20) } qr/\QCannot assign a value to a read-only accessor/,
    'cannot set read-only class attribute';

my $child = 'Child';
is $child->ReadOnlyAttribute => 30, q{Child class can extend parent's class attribute};
can_ok $child => 'YetAnotherAttribute';
