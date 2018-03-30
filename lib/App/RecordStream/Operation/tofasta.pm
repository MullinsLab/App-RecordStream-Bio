package App::RecordStream::Operation::tofasta;

use strict;
use warnings;

use base qw(App::RecordStream::Operation);
use JSON::MaybeXS qw< encode_json >;

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
        "fastj"             => \($self->{FASTJ}),
    };

    $self->parse_options($args, $spec);

    die "--passthru is incompatible with --oneline and --width\n\n"
        if $self->{PASSTHRU} and ($self->{ONELINE} or $self->{WIDTH});

    $self->{WIDTH} ||= 60;

    $self->{KEYS}{id}    = $id;
    $self->{KEYS}{desc}  = $desc;
    $self->{KEYS}{seq}   = $seq;
}

sub accept_record {
    my $self   = shift;
    my $record = shift;

    my %props = map {; "-$_" => ${$record->guess_key_from_spec($self->{KEYS}{$_})} }
                grep { $self->{KEYS}{$_} ne 'NONE' }
                keys %{$self->{KEYS}};

    if (not $self->{PASSTHRU} and defined $props{'-seq'}) {
        $props{'-seq'} =~ s/\s+//g; # fixme

        if ($self->{ONELINE}) {
            $props{'-seq'} =~ s/[\n\r]//g;
        } elsif ($self->{WIDTH}) {
            my $width = $self->{WIDTH} + 0;
            $props{'-seq'} =~ s/(.{$width})/$1\n/g;
        }
    }

    # Retain previous behaviour of preserving a leading space before any
    # description without --passthru
    $props{'-id'} = ""
        unless defined $props{'-id'} or $self->{PASSTHRU};

    # FASTJ puts a JSON object in the description field.  Copy any description
    # we already have into the JSON along with the rest of the record.
    #
    # XXX TODO: don't duplicate mapped $self->{KEYS} in the JSON.  This
    # requires adding something like a ->_generate_keydeletion_sub() method and
    # public API around it to KeySpec and hooking that into Records so that we
    # can remove a keyspec from a record.  An worse alternative is deep cloning
    # the record while skipping values which match the reference returned by
    # ->guess_key_from_spec().
    #   -trs, 30 March 2018
    if ($self->{FASTJ}) {
        $props{'-desc'} = encode_json({
            description => $props{'-desc'},
            %$record,
        });
    }

    my $fasta = sprintf ">%s\n%s",
        join(" ", map { s/[\n\r]//g; $_ }
                 grep { defined }
                      @props{'-id', '-desc'}),
        $props{'-seq'} || "";

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
        [ 'fastj',                      'Encode input record as JSON into the sequence "description"' ],
    ];

    my $args_string = $self->options_string($options);

    return <<USAGE;
Usage: recs-tofasta <options> [files]
   __FORMAT_TEXT__
   Outputs a FASTA-formatted sequence for each record.

   By default the keys "id", "description", and "sequence" are used to build
   the FASTA format.  These defaults match up with what recs-fromfasta produces.
   The special key name "NONE" may be used to indicate that no key should be
   used, disabling the defaults.  Note that specifying NONE for --id will cause
   any --description to appear with a space between it and the line's ">",
   unless --passthru is also used.

   With the --fastj option, the entire input record is encoded as a JSON object
   and placed into the "description" of each FASTA sequence record.  Any standard,
   textual description specified by --description becomes a "description" key in
   the object.  This format is dubbed FASTJ and supports structured sequence
   metadata while remaining interchangable with all software that consumes
   FASTA.  See also: recs fromfasta --fastj
   __FORMAT_TEXT__

Arguments:
$args_string

Examples:
  # Remove gaps from a fasta file
  recs-fromfasta seqs.fa | recs-xform '{{sequence}} =~ s/-//g' | recs-tofasta > seqs-nogaps.fa
USAGE
}

1;
