package App::RecordStream::Operation::fromfasta;

use strict;
use warnings;

use base qw(App::RecordStream::Operation);

sub init {
    my $self = shift;
    my $args = shift;

    my $oneline = 0;
    my %options = (
        "oneline"   => \$oneline,
    );

    $self->parse_options($args, \%options);

    $self->{ONELINE} = $oneline;
}

sub accept_line {
    my $self = shift;
    my $line = shift;

    if ($line =~ /^>(.*)$/) {
        my $id = $1;
        $self->push_accumulated_record;
        $self->{RECORD} = App::RecordStream::Record->new( id => $id );
    } else {
        $self->{SEQUENCE} .= $line . ($self->{ONELINE} ? "" : "\n");
    }

    return 1;
}

sub push_accumulated_record {
    my $self = shift;
    if ( my $record = delete $self->{RECORD} ) {
        my $seq = delete $self->{SEQUENCE};
        chomp $seq if defined $seq;
        $record->set( sequence => $seq );
        $self->push_record( $record );
        return 1;
    } else {
        return 0;
    }
}

sub stream_done {
    my $self = shift;
    $self->push_accumulated_record;
}

sub usage {
  my $self = shift;

  my $options = [
    [ 'oneline', 'Strip any newlines from the sequence so it is one long line'],
  ];

  my $args_string = $self->options_string($options);

  return <<USAGE;
Usage: recs-fromfasta <args> [<files>]
   __FORMAT_TEXT__
   Each sequence from the FASTA input files (or stdin) produces an output
   record with the keys id and sequence.
   __FORMAT_TEXT__

Arguments:
$args_string

Examples:
   Parse a FASTA file into records, stripping newlines in the sequence
      recs-fromfasta --oneline < example.fasta
USAGE
}

1;
