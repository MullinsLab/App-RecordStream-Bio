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
        "width|w=i"         => \($self->{WIDTH}),
        "oneline"           => \($self->{ONELINE}),
        "passthru"          => \($self->{PASSTHRU}),
    };

    $self->parse_options($args, $spec);

    die "--passthru is incompatible with --oneline and --width\n\n"
        if $self->{PASSTHRU} and ($self->{ONELINE} or $self->{WIDTH});

    $self->{KEYS}{id}    = $id;
    $self->{KEYS}{desc}  = $desc;
    $self->{KEYS}{seq}   = $seq;
}

sub accept_record {
    my $self   = shift;
    my $record = shift;
    my $fasta;

    my %props = map {; "-$_" => ${$record->guess_key_from_spec($self->{KEYS}{$_})} }
                grep { $self->{KEYS}{$_} ne 'NONE' }
                keys %{$self->{KEYS}};

    if ($self->{PASSTHRU}) {
        $fasta = sprintf ">%s\n%s",
            join(" ", map { s/[\n\r]//g; $_ }
                     grep { defined and length }
                          $props{'-id'}, $props{'-desc'}),
            $props{'-seq'} || "";
    } else {
        # Bio::SeqIO complains fatally about spaces
        $props{'-seq'} =~ s/\s+//g if defined $props{'-seq'};

        my $seq = Bio::Seq->new(%props);

        open my $buf, '>', \$fasta
            or die "Can't open string for writing: $!";
        my $io = Bio::SeqIO->new( -fh => $buf, -format => 'fasta' );
        $io->width($self->{WIDTH}) if $self->{WIDTH};
        $io->write_seq($seq);
        chomp $fasta;

        if ($self->{ONELINE}) {
            # Kind hacky, but nicer than abusing width's use by Bio::SeqIO::fasta
            # in an unpack() template.  Also clearer than using a regex to remove
            # all newlines following the first.
            my @lines = split /\n/, $fasta;
            $fasta = join "\n",
                        shift @lines,    # description line
                        join "", @lines; # rest of seq as a single line
        }
    }

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
        [ 'width|w <#>',                'Format sequence blocks to # characters wide' ],
        [ 'oneline',                    'Format sequences on a single long line' ],
        [ 'passthru',                   'Pass through nucleotides unformatted' ],
    ];

    my $args_string = $self->options_string($options);

    return <<USAGE;
Usage: recs-tofasta <options> [files]
   __FORMAT_TEXT__
   Outputs a FASTA-formatted sequence for each record.

   By default the keys "id", "description", and "sequence" are used to build
   the FASTA format.  These defaults match up with what recs-fromfasta produces.
   The special key name "NONE" may be used to indicate that no key should be
   used, disabling the defaults.  Note that warnings may be generated if you
   specify NONE for --id without specifying --passthru.
   __FORMAT_TEXT__

Arguments:
$args_string

Examples:
  # Remove gaps from a fasta file
  recs-fromfasta seqs.fa | recs-xform '{{sequence}} =~ s/-//g' | recs-tofasta > seqs-nogaps.fa
USAGE
}

1;
