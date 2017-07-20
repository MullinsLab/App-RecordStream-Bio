# NAME

App::RecordStream::Bio - A collection of record-handling tools related to biology

# SYNOPSIS

    # Turn a FASTA into a CSV after filtering for sequence names containing the
    # words POL or GAG.
    recs fromfasta --oneline < seqs.fasta           \
        | recs grep '{{id}} =~ /\b(POL|GAG)\b/i'    \
        | recs tocsv -k id,sequence
    
    # Filter gaps from sequences
    recs fromfasta seqs.fasta \
        | recs xform '{{seq}} =~ s/-//g' \
        | recs tofasta > seqs-nogaps.fasta

    # Calculate average mapping quality from SAM reads
    recs fromsam input.sam \
        | recs collate -a avg,mapq

# DESCRIPTION

App::RecordStream::Bio is a collection of record-handling tools related to
biology built upon the excellent [App::RecordStream](https://metacpan.org/pod/App::RecordStream).

The operations themselves are written as classes, but you'll almost always use
them via their command line wrappers within a larger record stream pipeline.

# TOOLS

[recs-fromfasta](https://metacpan.org/pod/recs-fromfasta)

[recs-fromgff3](https://metacpan.org/pod/recs-fromgff3)

[recs-fromsam](https://metacpan.org/pod/recs-fromsam)

[recs-tofasta](https://metacpan.org/pod/recs-tofasta)

Looking for `fromfastq` or `tofastq`?  Install the
[recs-fastq](https://github.com/MullinsLab/recs-fastq) package.

# INSTALLATION

## Quick, standalone bundle

The quickest way to start using these tools is via the minimal, standalone
bundle (also known as the "fatpacked" version).  First, grab
[recs](https://metacpan.org/pod/App::RecordStream#INSTALLATION) if you don't already have it:

    curl -fsSL https://recs.pl > recs
    chmod +x recs

Then grab these bio tools and put them in place for recs:

    mkdir -p ~/.recs/site/
    curl -fsSL https://recs.pl/bio > ~/.recs/site/bio.pm

Congrats, you should now be able to run:

    ./recs fromfasta --help
    ./recs tofasta --help
    ./recs fromsam --help

recs version 4.0.14 or newer is required to support site loading from
`~/.recs/site`.

## From CPAN

You can also install from [CPAN](http://cpan.org) as App::RecordStream::Bio:

    cpanm App::RecordStream::Bio

Other CPAN clients such as [cpan](https://metacpan.org/pod/cpan) and [cpanp](https://metacpan.org/pod/cpanp) also work just great.

If you don't have [cpanm](https://metacpan.org/pod/cpanm) itself, you can install it easily with:

    curl -fsSL https://cpanmin.us | perl - App::cpanminus

# AUTHOR

Thomas Sibley <trsibley@uw.edu>

# COPYRIGHT

Copyright 2014-2017 Mullins Lab, Department of Microbiology, University of Washington

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[App::RecordStream](https://metacpan.org/pod/App::RecordStream)
