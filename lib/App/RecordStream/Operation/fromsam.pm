use strict;
use warnings;

package App::RecordStream::Operation::fromsam;
use base qw(App::RecordStream::Operation);

sub init {
    my $this = shift;
    my $args = shift;
    my $options = {};
    $this->parse_options($args, $options);  # Ensures we pick up the automatic options
}

sub accept_line {
  my $this = shift;
  my $line = shift;
  return 1 if $line =~ /^@/;  # Skip any header

  # Parse the mandatory fields
  my @fields = qw[ qname flag rname pos mapq cigar rnext pnext tlen seq qual ];
  my @values = split /\t/, $line;
  my %record = map { $_ => shift @values } @fields;

  # The remaining values are optional fields, which are composed of three parts
  # separated by a colon: TAG:TYPE:VALUE
  for my $tag (map { [split /:/, $_, 3] } @values) {
    $record{tag}{ $tag->[0] } = {
      type  => $tag->[1],
      value => $tag->[2],
    };
  }

  $this->push_record( App::RecordStream::Record->new(\%record) );
  return 1;
}

sub usage {
  my $this = shift;
  my $options = [];
  my $args_string = $this->options_string($options);

  return <<USAGE;
Usage: recs fromsam <args> [<files>]
   __FORMAT_TEXT__
   Each line of input (or lines of <files>) is parsed as a SAM (Sequence
   Alignment/Map) formatted record to produce a recs output record.  To parse a
   BAM file, please pipe it from \`samtools view file.bam\` into this command.

   The output records will contain the following fields:
   __FORMAT_TEXT__

      qname flag rname pos mapq cigar rnext pnext tlen seq qual

   __FORMAT_TEXT__
   Additional optional SAM fields are parsed into the "tag" key, which is a
   hash keyed by the SAM field tag name.  The values are also hashes containing
   a "type" and "value" field.  For example, a read group tag will end up in your
   record like this:
   __FORMAT_TEXT__

      tags => {
        RG => {
          type  => "Z",
          value => "...",
        }
      }

   __FORMAT_TEXT__
   Refer to the SAM spec for field details: http://samtools.github.io/hts-specs/SAMv1.pdf
   __FORMAT_TEXT__

Arguments:
$args_string

Examples:
   Parse SAM and calculate average mapping quality:
      recs fromsam input.sam | recs collate -a avg,mapq
   Parse BAM:
      samtools view input.bam | recs fromsam
   Parse SAM pre-filtered by read group:
      samtools view -r SAMPLE-1234 input.sam | recs fromsam
   The same, but probably slower:
      recs fromsam input.sam | recs grep '{{tag/RG/value}} eq "SAMPLE-1234"'
USAGE
}

1;
