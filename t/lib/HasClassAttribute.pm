package HasClassAttribute;

use Mouse;
use MouseX::ClassAttribute;

our $Lazy = 0;

class_has 'ObjectCount' => (
    is        => 'rw',
    isa       => 'Int',
    default   => 0,
);

class_has 'WeakAttribute' => (
    is        => 'rw',
    isa       => 'Object',
    weak_ref  => 1,
);

class_has 'LazyAttribute' => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => sub { $Lazy = 1 },
);

class_has 'ReadOnlyAttribute' => (
    is      => 'ro',
    isa     => 'Int',
    default => 10,
);

has 'instance_attribute' => (
    is      => 'rw',
    isa     => 'Int',
    default => 5,
);

no Mouse;

sub BUILD {
    my $self = shift;
    $self->ObjectCount( $self->ObjectCount + 1 );
}

1;
