package App::RecordStream::Bio;

use strict;
use 5.010;
our $VERSION = '0.10';

1;
__END__

=encoding utf-8

=head1 NAME

App::RecordStream::Bio - A collection of record-handling tools related to biology

=head1 SYNOPSIS

    # Turn a FASTA into a CSV after filtering for sequence names containing the
    # words POL or GAG.
    recs-fromfasta --oneline < seqs.fasta           \
        | recs-grep '{{id}} =~ /\b(POL|GAG)\b/i'    \
        | recs-tocsv -k id,sequence
    
    # Filter gaps from sequences
    recs-fromfasta seqs.fasta \
        | recs-xform '{{seq}} =~ s/-//g' \
        | recs-tofasta > seqs-nogaps.fasta

=head1 DESCRIPTION

App::RecordStream::Bio is a collection of record-handling tools related to
biology built upon the excellent L<App::RecordStream>.

The operations themselves are written as classes, but you'll almost always use
them via their command line wrappers within a larger record stream pipeline.

=head1 TOOLS

L<recs-fromfasta>

L<recs-tofasta>

=head1 AUTHOR

Thomas Sibley E<lt>trsibley@uw.eduE<gt>

=head1 COPYRIGHT

Copyright 2014- Mullins Lab, Department of Microbiology, University of Washington

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<App::RecordStream>

=cut
