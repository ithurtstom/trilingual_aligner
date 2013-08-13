#!/usr/bin/perl

# original script based on and included in LFaligner <http://sourceforge.net/projects/aligner/>
# major modifications by Thomas Meyer <ithurtstom@gmail.com>
# 13.08.2013

#This script is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License version 3 as
#published by the Free Software Foundation.

#The script is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this script. If not, see <http://www.gnu.org/licenses/>.

# Usage:
# the script will only be called from trilingual_processing.pl
# it however needs hunalign to be correctly executed <http://mokk.bme.hu/resources/hunalign/>
# or is directly included in the LFaligner package as well.
# change below to your local directories

use strict;
use warnings;

################################################################


######## FIRST ALIGNMENT PASS IN THE 3 LANGUAGE ALIGNER ########


################################################################

my $l1 = $ARGV[0];
my $l2 = $ARGV[1];
my $l3 = $ARGV[2];

my $folder = "/scratch/tmeyer/trialign6";

my $file1 = "$folder/$l1.txt";
my $file2 = "$folder/$l2.txt";
my $file3 = "$folder/$l3.txt";

$file1 =~ /.*?([a-z]{1,2}\d{1,4})\.txt/; # $file1 =~ /.*?([a-z]{1,2})\.txt/;
my $f1 = $1;
	
$file2 =~ /.*?([a-z]{1,2}\d{1,4})\.txt/;
my $f2 = $1;
	
$file3 =~ /.*?([a-z]{1,2}\d{1,4})\.txt/;
my $f3 = $1;

my $alignfilename = "${f1}-${f2}";

my $hunpath = "/idiap/home/tmeyer/Desktop/hunalign";
my $hunalign_bin = "$hunpath/src/hunalign/hunalign";

my $hunalign_dic = "null.dic";		# empty dictionary in case there's no dictionary for the language pair

print "\n\n-------------------------------------------------";
print "\n\nAligning...\n";
print "\n\nDictionary used by Hunalign: $hunalign_dic\n\n";

print "\nUsing Hunalign in normal mode\n";
	
`$hunalign_bin -text $hunpath/data/$hunalign_dic $file1 $file2 > $folder/aligned_${alignfilename}.txt`;

# SEE IF ALIGNED FILE IS OK, ABORT IF NOT

my $alignedfilesize = -s "$folder/aligned_${alignfilename}.txt";
if ($alignedfilesize == 0) {
	print "\n\n-------------------------------------------------";
	print "\n\nAlign failed (probably due to one file being empty or very short). ABORTING...\n\n";
	unlink "$folder/aligned_${alignfilename}.txt";
	abort();
} else {
	open (ALIGNED, "<:encoding(UTF-8)", "$folder/aligned_${alignfilename}.txt") or print "Can't open aligned file for line count: $!";
	while (<ALIGNED>) {};
		$. --;					# correct the line count for the log
		print "\nAligned file: $. lines, $alignedfilesize bytes ($folder/aligned_${alignfilename}.txt)";
	close ALIGNED;
}


# copy ("$folder/aligned_${alignfilename}.txt", "$folder/source_files_backup/aligned_unprocessed_${alignfilename}.txt") or print "Cannot make backup of aligned file: $!"; # cleanup is optional anyway

open (ALIGNED, "<:encoding(UTF-8)", "$folder/aligned_${alignfilename}.txt") or die "Can't open aligned file for reading: $!";
open (ALIGNED_MOD, ">:encoding(UTF-8)", "$folder/aligned_${alignfilename}_mod.txt") or die "Can't open file for writing: $!";

# delete empty records (hunalign creates 1 or 2 at the end)
while (<ALIGNED>) {
	s/^\t\t.*\n//;
	print ALIGNED_MOD $_;
}
ren_aligned ();


# CLEANUP
# cleanup is mandatory in 3lang 1st pass, ~~~ has to go #3l
while (<ALIGNED>) {
	s/ ~~~//g;				# remove ~~~ inserted by Hunalign #3l
	s/^- //;				# remove segment starting "- "
	s/\t- /\t/;				# remove segment starting "- "
	print ALIGNED_MOD $_;
}
ren_aligned ();


#if ($cleanup_remove_conf_value eq "y") {#always done in 3lang #3l
while (<ALIGNED>) {
	s/([^\t]*\t[^\t]*).*$/$1/;
	print ALIGNED_MOD $_;
}
ren_aligned ();


##################################################

# FIRST PASS DONE, EXTRACT L1 TEXT FOR SECOND PASS

##################################################


# ALIGNED ($folder/aligned_${alignfilename}.txt)

# extract L1

open (L1, ">:encoding(UTF-8)", "$folder/${f1}.txt") or die "Can't open file: $!";

while (<ALIGNED>) {
	s/^([^\t]*).*/$1/g; # remove everything from the first tab on
	s/^\n/\[null\]\n/;
	print L1 $_;
}
close L1;


##################################################

# ALIGN L1 with L3

##################################################

# save old alignfilename
my $alignfilename_l1l2 = $alignfilename;  #hiba

# set new alignfilename
$alignfilename = "${f1}-${f3}";

$hunalign_dic = "null.dic";		# empty dictionary in case there's no dictionary for the language pair #3l "my" removed

print "\n\n-------------------------------------------------";
print "\n\nAligning...\n";
print "\n\nDictionary used by Hunalign: $hunalign_dic\n\n";

# NON-CHOPPING MODE
print "\nUsing Hunalign in normal mode\n";

`$hunalign_bin -text $hunpath/data/$hunalign_dic $file1 $file3 > $folder/aligned_${alignfilename}.txt`;

# SEE IF ALIGNED FILE IS OK, ABORT IF NOT

$alignedfilesize = -s "$folder/aligned_${alignfilename}.txt"; #3l "my" deleted
if ($alignedfilesize == 0) {
	print "\n\n-------------------------------------------------";
	print "\n\nAlign failed (probably due to one file being empty or very short). ABORTING...\n\n";
	unlink "$folder/aligned_${alignfilename}.txt";
	abort();
} else {
	open (ALIGNED, "<:encoding(UTF-8)", "$folder/aligned_${alignfilename}.txt") or print "Can't open aligned file for line count: $!";
	while (<ALIGNED>) {};
		$. --;					# correct the line count for the log
		print "\nAligned file: $. lines, $alignedfilesize bytes ($folder/aligned_${alignfilename}.txt)";
	close ALIGNED;
}


# copy ("$folder/aligned_${alignfilename}.txt", "$folder/source_files_backup/aligned_unprocessed_${alignfilename}.txt") or print "Cannot make backup of aligned file: $!"; # cleanup is optional anyway

open (ALIGNED, "<:encoding(UTF-8)", "$folder/aligned_${alignfilename}.txt") or die "Can't open aligned file for reading: $!";
open (ALIGNED_MOD, ">:encoding(UTF-8)", "$folder/aligned_${alignfilename}_mod.txt") or die "Can't open file for writing: $!";

# delete empty records (hunalign creates 1 or 2 at the end)
while (<ALIGNED>) {
	s/^\t\t.*\n//;
	print ALIGNED_MOD $_;
}
ren_aligned ();


# CLEANUP

#if ($cleanup_remove_conf_value eq "y") {#always done in 3lang #3l
while (<ALIGNED>) {
	s/([^\t]*\t[^\t]*).*$/$1/;
	print ALIGNED_MOD $_;
}
ren_aligned ();

# filter out dupes - not done in 3lang mode #3l

# delete if L1 = L2 - not done in 3lang mode #3l

# Add BOM to aligned txt (only at the end for the sake of the duplicate & untranslated filter) - not in 3lang #3l

# ADD ALIGNFILENAME IN 3rd COLUMN, PUSH CURRENT 3rd TO 4th - not in 3lang in the first pass #3l

# CHARACTER CONVERSION DISABLED IN 3LANG #3l

# UNDO SEGMENT MERGING DONE BY HUNALIGN IN L1
my $repeat;
REPEAT:
$repeat = "0";
while (<ALIGNED>) { #
	s/^([^\t]*) ~~~ ([^\t]*)\t(.*)$/$1\t$3\n$2\t$3/; #not /g!
	if (/^[^\t]* ~~~ /) {$repeat = "1"} # if there are still instances of ~~~ left in the text
	print ALIGNED_MOD;
}
ren_aligned ();

goto REPEAT if $repeat eq "1";

# MERGE BACK WHERE HUNALIGN STRETCHED APART

my $previous = "";
while (<ALIGNED>) {
	chomp;
	print ALIGNED_MOD $previous; # print previous line
	if (/^[^\t]/) {print ALIGNED_MOD "\n"} else {s/^\t/ /} # if first field of this line is empty, append to previous (don't print line break after previous)
	$previous = $_;
}
print ALIGNED_MOD $previous;
ren_aligned ();


# delete empty lines
while (<ALIGNED>) {
	s/^\s*\n//;
	print ALIGNED_MOD $_;
}
ren_aligned ();




# CLEANUP
while (<ALIGNED>) {
	s/ ~~~//g;				# remove ~~~ inserted by Hunalign
	s/^- //;				# remove segment starting "- "
	s/\t- /\t/;				# remove segment starting "- "
	print ALIGNED_MOD $_;
}
ren_aligned ();


# EXTRACT L3

open (L3, ">:encoding(UTF-8)", "$folder/${f3}.txt") or die "Can't open file: $!"; # overwrites old f3 file

while (<ALIGNED>) {
	s/^[^\t]*\t(.*)$/$1/g; # remove everything from the first tab on
	print L3 $_;
}
close ALIGNED;
close ALIGNED_MOD;
close L3;


#3l
# FROM HERE ON, WORK WITH L1-L2-L3
# keep old alignfilename
my $alignfilename_l1l3 = $alignfilename;
$alignfilename = "${f1}-${f2}-${f3}";
# specific reference to alignfilename 1-2-3
my $alignfilename_l1l2l3 = $alignfilename;


#3l
# CREATE TAB DELIMTED FILE OUT OF L1-L2 and L3
open(L1L2, "<:encoding(UTF-8)", "$folder/aligned_${alignfilename_l1l2}.txt") or die "Can't open file: $!";
open(L3, "<:encoding(UTF-8)", "$folder/${f3}.txt") or die "Can't open file: $!";
open(L1L2L3, ">>:encoding(UTF-8)", "$folder/aligned_${alignfilename}.txt") or die "Can't open file: $!";

#3l
until( eof(L1L2) and eof (L3) ) 
{
    my $col_1 = <L1L2>;
    my $col_2 = <L3>;
    $col_1 ||= "";
    $col_2 ||= "";
    chomp($col_1);
    chomp($col_2);
    print L1L2L3 "$col_1\t$col_2\n";
}
close L1L2;
close L3;
close L1L2L3;
open (ALIGNED, "<:encoding(UTF-8)", "$folder/aligned_${alignfilename}.txt") or die "Can't open file for reading: $!";
open (ALIGNED_MOD, ">:encoding(UTF-8)", "$folder/aligned_${alignfilename}_mod.txt") or die "Can't open file for writing: $!";

#3l
# ADD NOTE IN 4th COLUMN
while (<ALIGNED>) {
	chomp $_;
	s/([^\t]*\t[^\t]*\t[^\t]*)(.*)$/$1\t$alignfilename$2\n/;
	print ALIGNED_MOD $_;
}
ren_aligned ();

unlink "$folder/aligned_${f1}-${f2}_mod.txt";
unlink "$folder/aligned_${f1}-${f3}_mod.txt";
unlink "$folder/aligned_${f1}-${f2}-${f3}_mod.txt";
unlink "$folder/aligned_${f1}-${f2}.txt";
unlink "$folder/aligned_${f1}-${f3}.txt";
unlink "$folder/${f1}_mod.txt";
unlink "$folder/${f2}_mod.txt";
unlink "$folder/${f3}_mod.txt";
unlink "$folder/${f1}-${f2}.txt";

sub ren_aligned { # renaming intermediate files

	close ALIGNED;
	close ALIGNED_MOD;
	rename ("$folder/aligned_${alignfilename}_mod.txt", "$folder/aligned_${alignfilename}.txt") or die "Can't rename file: $!";

	open (ALIGNED, "<:encoding(UTF-8)", "$folder/aligned_${alignfilename}.txt") or die "Can't open file for reading: $!";
	open (ALIGNED_MOD, ">:encoding(UTF-8)", "$folder/aligned_${alignfilename}_mod.txt") or die "Can't open file for writing: $!";
}

sub abort { # aborting and deleting intermediate files

	close ALIGNED;
	close ALIGNED_MOD;

	unlink "$folder/aligned_${alignfilename}_mod.txt";
	unlink "$folder/${f1}_mod.txt";
	unlink "$folder/${f2}_mod.txt";

	sleep 5;
	print "Press enter to close this window. ";
	<STDIN>;
	die;
}
