#!/usr/bin/perl

# written by Thomas Meyer <ithurtstom@gmail.com>
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
# processing steps to obtain trilingual sentence alignments.
# calls the scripts trilingual_aligner, which in turn needs hunalign to run
# filenames in unifydirectories() are europarl corpus - specific, change if needed
# run: ./trilingual_processing EN DE FR or similar

use strict;
use warnings;

my $lang1 = $ARGV[0];
my $lang2 = $ARGV[1];
my $lang3 = $ARGV[2];

my $indir = "/scratch/tmeyer/trialign6";
my $outdir1 = "$indir/out/$lang1"; # *** make sure these folders exist ***
my $outdir2 = "$indir/out/$lang2";
my $outdir3 = "$indir/out/$lang3";

my $origdir = "$indir/orig";
my %originalfiles; # hash to store the original daily text file names

my $alignedfile;

my $outfile1;
my $outfile2;
my $outfile3;

my $lang1line;
my $lang2line;
my $lang3line;

############## watch out for the lang.-dependent part in &preprocessing()

unifydirectories();
preprocessing();
alignment();
postprocessing();

##############

sub unifydirectories
{
	my @A = <$origdir/$lang1/*>; #lang 1
	my @B = <$origdir/$lang2/*>; #lang 2
	my @C = <$origdir/$lang3/*>; #lang 3
	
	my @filename1;
	my @filename2;
	my @filename3;

foreach my $element1 (@A) {
	$element1 =~ /.*?(ep.*)/;
	my $filename = $1;
	push (@filename1, $filename);
}

foreach my $element2 (@B) {
	$element2 =~ /.*?(ep.*)/;
	my $filename = $1;
	push (@filename2, $filename);
}

foreach my $element3 (@C) {
	$element3 =~ /.*?(ep.*)/;
	my $filename = $1;
	push (@filename3, $filename);
}

my %seen1;         # lookup table 1
my %seen2;	   	   # lookup table 2
my %common;    	   # common files

# build lookup table
@seen1{@filename2} = ( );
@seen2{@filename3} = ( );

foreach my $element (@filename1) {
    if (exists $seen1{$element} && exists $seen2{$element}) {
    	$common{$element} = 1;
    }
}

foreach my $file (@filename1) {
		unlink "$origdir/$lang1/$file" unless exists $common{$file};
}

foreach my $file (@filename2) {
		unlink "$origdir/$lang2/$file" unless exists $common{$file};
}

foreach my $file (@filename3) {
		unlink "$origdir/$lang3/$file" unless exists $common{$file};
}		

}

sub preprocessing 
{
	my @A = <$origdir/$lang1/*>; #lang 1
	my @B = <$origdir/$lang2/*>; #lang 2
	my @C = <$origdir/$lang3/*>; #lang 3
	
	my @filename1;
	my @filename2;
	my @filename3;
	
	foreach my $element1 (@A) {
		$element1 =~ /.*?(ep.*)/;
		my $filename = $1;
		push (@filename1, $filename);
	}

	foreach my $element2 (@B) {
		$element2 =~ /.*?(ep.*)/;
		my $filename = $1;
		push (@filename2, $filename);
	}

	foreach my $element3 (@C) {
		$element3 =~ /.*?(ep.*)/;
		my $filename = $1;
		push (@filename3, $filename);
	}
	

	for (my $i = 0; $i <= $#filename1; $i++) {	
		my $j = $i + 1;
		# syntax: regex, file it should be applied to
		`rename 's/$filename1[$i]/$lang1$j\.txt/' $A[$i]`;
		# store the original file name in a hash to recover it at the end.
		$originalfiles{$lang1.$j} = $filename1[$i];
		`rename 's/$filename2[$i]/$lang2$j\.txt/' $B[$i]`;
		$originalfiles{$lang2.$j} = $filename2[$i];
		`rename 's/$filename3[$i]/$lang3$j\.txt/' $C[$i]`;
		$originalfiles{$lang3.$j} = $filename3[$i];
		
	}
	# *** this part, for removing files is language dependent !!! check with a first alignment run on
	# which files are problematic ***
	#EN-FR-DE my @problems = ("1200","1805","237","2510","2511","2512","2513","3171","378","4025","4026","4045","4046","7363");
	#EN-FR-IT my @problems = ("235","236","237","238","239","240","241","242","243","244","245","246","247","248","249","250","251","252","253","254","255","256","257","258","259","260","261","262","263","264","265","266","267","268","269","270","271","272","273","274","275","276","277","278","279","280","281","282","283","284","285","286","287","288","289","290","291","292","293","294","295","296","297","298","299","300","301","302","303","304","305","306","307","308","309","310","311","312","313","314","315","316","317","318","319","320","321","322","323","324","325","326","327","328","329","330","331","332","333","334","335","336","337","338","339","340","341","342","343","344","345","346","347","348","349","350","351","352","353","354","355","356","357","358","359","360","361","362","363","364","365","366","367","368","369","370","371","372","373","374","375","376","377","378","379","380","381","382","383","384","385","386","387","388","389","390","391","392","393","394","395","396","397","398","399","1205","1440","1812","3178","6441","6495","7625","7741","7791");
	#FR-EN-IT my @problems = ("4","341","824","1233","2091","5075","5420","7791");
	#IT-EN-FR my @problems = ("4","18","235","236","237","238","239","240","241","242","243","244","245","246","247","248","249","250","251","252","253","254","255","256","257","258","259","260","261","262","263","264","265","266","267","268","269","270","271","272","273","274","275","276","277","278","279","280","281","282","283","284","285","286","287","288","289","290","291","292","293","294","295","296","297","298","299","300","301","302","303","304","305","306","307","308","309","310","311","312","313","314","315","316","317","318","319","320","321","322","323","324","325","326","327","328","329","330","331","332","333","334","335","336","337","338","339","340","341","342","343","344","345","346","347","348","349","350","351","352","353","354","355","356","357","358","359","360","361","362","362","363","364","365","366","367","368","369","370","371","372","373","374","375","376","377","378","379","380","381","382","383","384","385","386","387","388","389","390","391","392","393","394","395","396","397","398","399","7804");
	#EN-DE-IT my @problems = ("235","236","237","238","239","240","241","242","243","244","245","246","247","248","249","250","251","252","253","254","255","256","257","258","259","260","261","262","263","264","265","266","267","268","269","270","271","272","273","274","275","276","277","278","279","280","281","282","283","284","285","286","287","288","289","290","291","292","293","294","295","296","297","298","299","300","301","302","303","304","305","306","307","308","309","310","311","312","313","314","315","316","317","318","319","320","321","322","323","324","325","326","327","328","329","330","331","332","333","334","335","336","337","338","339","340","341","342","343","344","345","346","347","348","349","350","351","352","353","354","355","356","357","358","359","360","361","362","363","364","365","366","367","368","369","370","371","372","373","374","375","376","377","378","379","380","381","382","383","384","385","386","387","388","389","390","391","392","393","394","395","396","397","398","399","1433","2509","2510","2511","2512","4024","4025","4044","4045","6192","6246","7492","7542");
	
	my @problems = ("4","10","12","13","23","30","33","233","234","235","236","237","238","239","240","241","242","243","244","245","246","247","248","249","250","251","252","253","254","255","256","257","258","259","260","261","262","263","264","265","266","267","268","269","270","271","272","273","274","275","276","277","278","279","280","281","282","283","284","285","286","287","288","289","290","291","292","293","294","295","296","297","298","299","300","301","302","303","304","305","306","307","308","309","310","311","312","313","314","315","316","317","318","319","320","321","322","323","324","325","326","327","328","329","330","331","332","333","334","335","336","337","338","339","340","341","342","343","344","345","346","347","348","349","350","351","352","353","354","355","356","357","358","359","360","361","362","363","364","365","366","367","368","369","370","371","372","373","374","375","376","377","378","379","380","381","382","383","384","385","386","387","388","389","390","391","392","393","394","1228","2752","2834","7541");
	
	foreach my $problem (@problems) {	
		unlink "$origdir/$lang1/$lang1"."$problem.txt";
		unlink "$origdir/$lang2/$lang2"."$problem.txt";
		unlink "$origdir/$lang3/$lang3"."$problem.txt";
	}
	
	# ***
		
		`cp $origdir/$lang1/*.txt $indir`;
		`cp $origdir/$lang2/*.txt $indir`;
		`cp $origdir/$lang3/*.txt $indir`;
}

sub alignment 
{
 
 my @files = <$indir/*.txt>;
 
 my @filenumbers;
 
 foreach my $element (@files) {
		if ($element =~ /$lang1(\d{1,5})/) {
			my $filenumber = $1;
			push (@filenumbers, $filenumber);
		}
 } 
 for (my $i = 0; $i <= $#filenumbers; $i++) {
	`/idiap/home/tmeyer/Documents/PhD-Resources/workspace/trilingual_alignment/trilingual_aligner.pl $lang1$filenumbers[$i] $lang2$filenumbers[$i] $lang3$filenumbers[$i]`;
 }
}


# only post-processing 
sub postprocessing 
{
	my @alignedfiles = <$indir/*>;
	
	my @filenames;
 
 	foreach my $element (@alignedfiles) {
 			if ($element =~ /(aligned\_$lang1\d{1,5}\-$lang2\d{1,5}\-$lang3\d{1,5}\.txt)/) {
			my $filename = $1;
			push (@filenames, $filename);
 		}
 	}
    
    for (my $i = 0; $i <= $#filenames; $i++) {
    		$filenames[$i] =~ /aligned\_($lang1\d{1,5})\-($lang2\d{1,5})\-($lang3\d{1,5})\.txt/;
    		my $name1 = $1;
    		my $name2 = $2;
    		my $name3 = $3;
        	$outfile1 = $outdir1."/".$originalfiles{$name1}; # substr($filenames[$i],rindex($filenames[$i],"/")+1).".$lang1";
        	$outfile2 = $outdir2."/".$originalfiles{$name2}; # substr($filenames[$i],rindex($filenames[$i],"/")+1).".$lang2";
        	$outfile3 = $outdir3."/".$originalfiles{$name3}; # substr($filenames[$i],rindex($filenames[$i],"/")+1).".$lang3";   
        	open (INPUT, "<$indir/$filenames[$i]") or die "Can't open file: $!";
        	open (OUTPUT1, ">$outfile1") or die "Can't create file: $!";
        	open (OUTPUT2, ">$outfile2") or die "Can't create file: $!";
        	open (OUTPUT3, ">$outfile3") or die "Can't create file: $!";

			while (<INPUT>) {
				$_ =~ /(.*?)\t(.*?)\t(.*?)\t/;
				$lang1line = $1;
				$lang2line = $2;
				$lang3line = $3;
				print OUTPUT1 "$lang1line\n";
				print OUTPUT2 "$lang2line\n";
				print OUTPUT3 "$lang3line\n";
			}
	}
	close (INPUT);
	close (OUTPUT1);
	close (OUTPUT2);
	close (OUTPUT3);
}
