trilingual_aligner
==================

Sentence-aligns text corpora of three languages

Usage
=====

Let's assume with have somewhat parallel texts available in three languages: English (EN), French (FR) and German (DE). Have these texts ready in either a bunch of X.en1, X.fr1, X.de1 ... X.enN, X.frN, X.deN text files or in just one file per language: X.en, X.fr, X.de

The scripts will look for sentences that exist in all languages and will output target files, that are parallel among the three languages, one sentence per line.

run: perl trilingual_processing.pl en fr de

Dependencies
============

The script trilingual_aligner.pl that comes with this package needs to be in the same path

The latter will call hunalign, an open-source sentence aligner, available here: http://mokk.bme.hu/resources/hunalign/

or as part of LFaligner: http://sourceforge.net/projects/aligner/
