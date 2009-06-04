use strict;
use warnings;

use Test::More;

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
    if $@;

# This is a stripped down version of all_pod_coverage_ok which lets us
# vary the trustme parameter per module.
my @modules = all_modules();
plan tests => scalar @modules;

my %trustme =
    ( 'MouseX::ClassAttribute'                         => [ 'import', 'unimport', 'class_has' ],
      #'MouseX::ClassAttribute::Role::Meta::Class'      => [ 'compute_all_applicable_class_attributes' ],
      'MouseX::ClassAttribute::Meta::Method::Accessor' => [ '.+' ],
    );

for my $module ( sort @modules )
{
    my $trustme;

    if ( $trustme{$module} )
    {
        my $methods = join '|', @{ $trustme{$module} };
        $trustme = [ qr/^(?:$methods)/ ];
    }

    pod_coverage_ok( $module, { trustme => $trustme },
                     "Pod coverage for $module"
                   );
}
