requires 'perl', '5.008005';

# minimum base version, just to start somewhere known.
requires 'App::RecordStream::Operation' => '4.0.0';

on test => sub {
    requires 'Test::More', '0.88';
    requires 'App::RecordStream::Test::Tester' => '4.0.0';
};

on develop => sub {
    requires 'Dist::Zilla::Plugin::Run::BeforeBuild';
};
