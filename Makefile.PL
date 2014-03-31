
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A collection of record-handling tools related to biology",
  "AUTHOR" => "Thomas Sibley <trsibley\@uw.edu>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "App-RecordStream-Bio",
  "EXE_FILES" => [
    "script/recs-fromfasta",
    "script/recs-tofasta"
  ],
  "LICENSE" => "perl",
  "NAME" => "App::RecordStream::Bio",
  "PREREQ_PM" => {
    "App::RecordStream::Operation" => "v4.0.0"
  },
  "TEST_REQUIRES" => {
    "App::RecordStream::Test::Tester" => "v4.0.0",
    "Test::More" => "0.88"
  },
  "VERSION" => "0.04",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "App::RecordStream::Operation" => "v4.0.0",
  "App::RecordStream::Test::Tester" => "v4.0.0",
  "Test::More" => "0.88"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



