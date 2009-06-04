use inc::Module::Install;
name 'MouseX-ClassAttribute';
all_from 'lib/MouseX/ClassAttribute.pm';

requires 'Mouse' => '0.23';
requires 'Mouse::Util::MetaRole';
requires 'MouseX::AttributeHelpers';
requires 'Exporter';
requires 'Carp';
requires 'Scalar::Util' => '1.14';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'FindBin';
test_requires 'MouseX::AttributeHelpers';
author_tests 'xt';
use_test_base;

auto_set_repository;
auto_include_deps;
WriteAll;
