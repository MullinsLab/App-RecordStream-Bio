requires 'perl', '5.008005';

requires 'App::RecordStream' => '4.0.0';     # minimum base version, just to start somewhere

on test => sub {
    requires 'Test::More', '0.88';
};
