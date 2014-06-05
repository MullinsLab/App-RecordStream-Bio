# NAME

App::RecordStream::Bio - A collection of record-handling tools related to biology

# SYNOPSIS

    # Turn a FASTA into a CSV after filtering for sequence names containing the
    # words POL or GAG.
    recs-fromfasta --oneline < seqs.fasta           \
        | recs-grep '{{id}} =~ /\b(POL|GAG)\b/i'    \
        | recs-tocsv -k id,sequence
    
    # Filter gaps from sequences
    recs-fromfasta seqs.fasta \
        | recs-xform '{{seq}} =~ s/-//g' \
        | recs-tofasta > seqs-nogaps.fasta

# DESCRIPTION

App::RecordStream::Bio is a collection of record-handling tools related to
biology built upon the excellent [App::RecordStream](https://metacpan.org/pod/App::RecordStream).

The operations themselves are written as classes, but you'll almost always use
them via their command line wrappers within a larger record stream pipeline.

# TOOLS

[recs-fromfasta](https://metacpan.org/pod/recs-fromfasta)

[recs-tofasta](https://metacpan.org/pod/recs-tofasta)

# AUTHOR

Thomas Sibley <trsibley@uw.edu>

# COPYRIGHT

Copyright 2014- Mullins Lab, Department of Microbiology, University of Washington

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[App::RecordStream](https://metacpan.org/pod/App::RecordStream)
