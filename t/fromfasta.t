use strict;
use warnings;
use Test::More 'no_plan';

use App::RecordStream::Test::Tester;

BEGIN { use_ok( 'App::RecordStream::Operation::fromfasta' ) };

my $input;
my $output;

my $tester = App::RecordStream::Test::Tester->new('fromfasta');

diag "basic input";
$input = <<'INPUT';
>foo baz bar
TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGG
GGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT
TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGG
GGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT
> baz 
SLYNTVAVLYYVHQR
>empty
>bogus
TCATTATATAATACAGTAGC>>CCCTCTATTGTGTGCATCAAAGG
INPUT
$output = <<'OUTPUT';
{"id":"foo","description":"baz bar","name":"foo baz bar","sequence":"TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGG\nGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT\nTCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGG\nGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT"}
{"id":"baz","description":null,"name":"baz", "sequence":"SLYNTVAVLYYVHQR"}
{"id":"empty","description":null,"name":"empty","sequence":null}
{"id":"bogus","description":null,"name":"bogus","sequence":"TCATTATATAATACAGTAGC>>CCCTCTATTGTGTGCATCAAAGG"}
OUTPUT
$tester->test_input([], $input, $output);

diag "--oneline";
$output = <<'OUTPUT';
{"id":"foo","description":"baz bar","name":"foo baz bar","sequence":"TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACTTCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT"}
{"id":"baz","description":null,"name":"baz", "sequence":"SLYNTVAVLYYVHQR"}
{"id":"empty","description":null,"name":"empty","sequence":null}
{"id":"bogus","description":null,"name":"bogus","sequence":"TCATTATATAATACAGTAGC>>CCCTCTATTGTGTGCATCAAAGG"}
OUTPUT
$tester->test_input(['--oneline'], $input, $output);
