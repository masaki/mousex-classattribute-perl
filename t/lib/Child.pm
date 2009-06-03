package Child;

use Mouse;
use MouseX::ClassAttribute;

extends 'HasClassAttribute';

class_has '+ReadOnlyAttribute' => (
    default => 30,
);

class_has 'YetAnotherAttribute' => (
    is      => 'ro',
    default => 'thing',
);

no Mouse;
1;
