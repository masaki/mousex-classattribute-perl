use strict;
use warnings;

use Test::More tests => 2;

{
    package MyClass;

    use MouseX::ClassAttribute;
    use MouseX::AttributeHelpers;

    class_has counter =>
        ( metaclass => 'Counter',
          is        => 'ro',
          provides  => { inc => 'inc_counter',
                       },
        );
}

is( MyClass->counter(), 0 );

MyClass->inc_counter();
is( MyClass->counter(), 1 );
