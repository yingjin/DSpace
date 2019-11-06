#!/usr/bin/perl -Wall

##
## Author: Ying Jin
##
## The script is to link streaming files to another location
##
# command to call
#
# ./buildohmslink-new.pl  --srcdir=/ds/data/dspace/streaming-new/ --descdir=/ds/data/httpd/root/ohms/cachefiles/ --predir=/ds/data/dspace/

use warnings;
use strict;
use Getopt::Long;
use Cwd;


#my $tsrcdir = "";
#my $tdestdir = "";
my $srcdir = "";
my $descdir = "";
my $predir = "/ds/data/dspace/";
my $result = GetOptions(       "srcdir=s"    => \$srcdir,
                               "descdir=s"  => \$descdir,
                               "predir=s" => \$predir);
# opions are required, check to make sure
if(($srcdir eq "") or ($descdir eq "") or ($predir eq "")){
    print "buildlink.pl --srcdir <srcdir> --descdir <descdir> --predir <predir>\n";
    exit;
}

# read dir
opendir (SRCDIR, "$srcdir") || die "can't opendir $srcdir: $!";;

my @typedirs = grep {-d "$srcdir/$_" && ! /^\.{1,2}$/} readdir(SRCDIR);

print @typedirs;

foreach my $typedir (@typedirs){

    opendir TYPEDIR, "$srcdir/$typedir" || die "can't opendir $srcdir/$typedir: $!";
    my @ramdirs = grep {-d "$srcdir/$typedir/$_" && ! /^\.{1,2}$/} readdir(TYPEDIR);

    print @ramdirs;

    foreach my $ramdir (@ramdirs){

	my $finaldir = $srcdir."/".$typedir."/".$ramdir;

	opendir FINALDIR, $finaldir || die "can't opendir $finaldir: $!";
    my @files = grep {/^file_.*.ohms/} readdir(FINALDIR);

	foreach my $filename (@files){
	    my $symbollink = readlink ("$finaldir/$filename");

	    my $newsymbollink = "";

	    if($symbollink =~ /^(..\/..\/..\/)(.*)/){

		$newsymbollink =  $predir.$2;
	    }
	    print ("ln -s $newsymbollink $descdir/$typedir/$ramdir/$filename");
	    `mkdir -p $descdir/$typedir/$ramdir`;
	    `ln -s  $newsymbollink $descdir/$typedir/$ramdir/$filename`;

	}
	close(FINALDIR)

    }
    close(TYPEDIR)
}
close(SRCDIR);

print("DONE\n");
