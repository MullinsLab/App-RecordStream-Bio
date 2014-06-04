use strict;
use warnings;
use Test::More 'no_plan';

use App::RecordStream::Test::OperationHelper;

BEGIN { use_ok( 'App::RecordStream::Operation::tofasta' ) };

my $input;
my $output;

diag "--passthru";
$input = <<'INPUT';
{"id":"foo","description":"baz bar","name":"foo baz bar","sequence":"TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATA\nATATATTACTTCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAA\nCGATGACATAATATATTACT","lower_seq":"tcattatataatacagtagcaaccctctattgtgtgcatcaaaggggaaactacgtgtgttatctcccaacgatgacata\natatattacttcattatataatacagtagcaaccctctattgtgtgcatcaaaggggaaactacgtgtgttatctcccaa\ncgatgacataatatattact","num":1}
{"id":"baz","description":null,"name":"baz", "sequence":"SLYNTVA\nVLYYVHQR","lower_seq":"slyntvavlyyvhqr","num":2}
{"id":"empty","description":null,"name":"empty","sequence":null,"lower_seq":null,"num":3}
{"id":"bogus","description":null,"name":"bogus","sequence":"TCATTATATAATACAGTAGC>>CCCTCTATTGTGTGCATCAAAGG","lower_seq":"tcattatataatacagtagc>>ccctctattgtgtgcatcaaagg","num":4}
{"id":"empty2","description":null,"name":"empty2","sequence":null,"lower_seq":null,"num":5}
INPUT
$output = <<'OUTPUT';
>foo baz bar
TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATA
ATATATTACTTCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAA
CGATGACATAATATATTACT
>baz
SLYNTVA
VLYYVHQR
>empty
>bogus
TCATTATATAATACAGTAGC>>CCCTCTATTGTGTGCATCAAAGG
>empty2
OUTPUT
App::RecordStream::Test::OperationHelper->test_output('tofasta' => ['--passthru'], $input, $output);

# Remove validation errors for BioPerl
$input =~ s/>//g;

diag "basic output";
$output = <<'OUTPUT';
>foo baz bar
TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGT
TATCTCCCAACGATGACATAATATATTACTTCATTATATAATACAGTAGCAACCCTCTAT
TGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT
>baz
SLYNTVAVLYYVHQR
>empty
>bogus
TCATTATATAATACAGTAGCCCCTCTATTGTGTGCATCAAAGG
>empty2
OUTPUT
App::RecordStream::Test::OperationHelper->test_output('tofasta' => [], $input, $output);

diag "--oneline";
$output = <<'OUTPUT';
>foo baz bar
TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACTTCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT
>baz
SLYNTVAVLYYVHQR
>empty
>bogus
TCATTATATAATACAGTAGCCCCTCTATTGTGTGCATCAAAGG
>empty2
OUTPUT
App::RecordStream::Test::OperationHelper->test_output('tofasta' => ['--oneline'], $input, $output);

diag "--width";
$output = <<'OUTPUT';
>foo baz bar
TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATC
AAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATA
ATATATTACTTCATTATATAATACAGTAGCAACCCTCTAT
TGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAA
CGATGACATAATATATTACT
>baz
SLYNTVAVLYYVHQR
>empty
>bogus
TCATTATATAATACAGTAGCCCCTCTATTGTGTGCATCAA
AGG
>empty2
OUTPUT
App::RecordStream::Test::OperationHelper->test_output('tofasta' => ['--width=40'], $input, $output);

diag "--id";
$output = <<'OUTPUT';
>1 baz bar
TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGT
TATCTCCCAACGATGACATAATATATTACTTCATTATATAATACAGTAGCAACCCTCTAT
TGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT
>2
SLYNTVAVLYYVHQR
>3
>4
TCATTATATAATACAGTAGCCCCTCTATTGTGTGCATCAAAGG
>5
OUTPUT
App::RecordStream::Test::OperationHelper->test_output('tofasta' => ['--id=num'], $input, $output);

diag "--description";
$output = <<'OUTPUT';
>1
TCATTATATAATACAGTAGCAACCCTCTATTGTGTGCATCAAAGGGGAAACTACGTGTGT
TATCTCCCAACGATGACATAATATATTACTTCATTATATAATACAGTAGCAACCCTCTAT
TGTGTGCATCAAAGGGGAAACTACGTGTGTTATCTCCCAACGATGACATAATATATTACT
>2
SLYNTVAVLYYVHQR
>3
>4
TCATTATATAATACAGTAGCCCCTCTATTGTGTGCATCAAAGG
>5
OUTPUT
App::RecordStream::Test::OperationHelper->test_output('tofasta' => ['--id=num', '--desc=doesnotexist'], $input, $output);

diag "--sequence";
$output = <<'OUTPUT';
>1
tcattatataatacagtagcaaccctctattgtgtgcatcaaaggggaaactacgtgtgt
tatctcccaacgatgacataatatattacttcattatataatacagtagcaaccctctat
tgtgtgcatcaaaggggaaactacgtgtgttatctcccaacgatgacataatatattact
>2
slyntvavlyyvhqr
>3
>4
tcattatataatacagtagcccctctattgtgtgcatcaaagg
>5
OUTPUT
App::RecordStream::Test::OperationHelper->test_output('tofasta' => ['--id=num', '--desc=doesnotexist', '--seq=lower_seq'], $input, $output);
