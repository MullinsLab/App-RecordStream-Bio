use strict;
use warnings;
use Test::More 'no_plan';
use File::Basename qw< dirname >;

use App::RecordStream::Test::Tester;
use App::RecordStream::Test::OperationHelper;

use App::RecordStream::Operation::fromsam;

my $tester = App::RecordStream::Test::Tester->new('fromsam');
my ($input, $output) = map {
    open my $fh, '<', dirname(__FILE__) . "/data/fromsam-$_"
        or die "error opening t/data/fromsam-$_: $!";
    local $/;
    scalar <$fh>;
} qw[input output];

diag "basic input";
$tester->test_input([], $input, $output);
