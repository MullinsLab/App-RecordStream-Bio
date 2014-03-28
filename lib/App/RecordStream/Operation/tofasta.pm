package App::RecordStream::Operation::tofasta;

use strict;
use warnings;

use base qw(App::RecordStream::Operation);

use Bio::Seq;
use Bio::SeqIO;

sub init {
    my $self = shift;
    my $args = shift;

    my ($id, $desc, $seq) = qw(id description sequence);
    my $spec = {
        "id|i=s"            => \$id,
        "description|d=s"   => \$desc,
        "sequence|s=s"      => \$seq,
    };

    $self->parse_options($args, $spec);

    $self->{KEYS}{id}    = $id;
    $self->{KEYS}{desc}  = $desc;
    $self->{KEYS}{seq}   = $seq;
}

sub accept_record {
    my $self   = shift;
    my $record = shift;

    my %props = map {; "-$_" => ${$record->guess_key_from_spec($self->{KEYS}{$_})} }
                keys %{$self->{KEYS}};

    # Bio::SeqIO complains fatally about spaces
    $props{'-seq'} =~ s/\s+//g if defined $props{'-seq'};

    my $seq = Bio::Seq->new(%props);

    open my $buf, '>', \(my $fasta)
        or die "Can't open string for writing: $!";
    my $io = Bio::SeqIO->new( -fh => $buf, -format => 'fasta' );
    $io->write_seq($seq);
    chomp $fasta;

    $self->push_line($fasta);

    return 1;
}

sub add_help_types {
    my $self = shift;
    $self->use_help_type('keyspecs');
    $self->use_help_type('keys');
}

sub usage {
    my $self = shift;

    my $options = [
        [ 'id|-i <keyspec>',            'Record field to use for the sequence id' ],
        [ 'description|-d <keyspec>',   'Record field to use for the sequence description' ],
        [ 'sequence|-s <keyspec>',      'Record field to use for the sequence itself' ],
    ];

    my $args_string = $self->options_string($options);

    return <<USAGE;
Usage: recs-tofasta <options> [files]
   __FORMAT_TEXT__
   Outputs a FASTA-formatted sequence for each record.

   By default the keys "id", "description", and "sequence" are used to build
   the FASTA format.  These defaults match up with what recs-fromfasta produces.
   __FORMAT_TEXT__

Arguments:
$args_string

Examples:
  # Remove gaps from a fasta file
  recs-fromfasta seqs.fa | recs-xform '{{sequence}} =~ s/-//g' | recs-tofasta > seqs-nogaps.fa
USAGE
}

1;
