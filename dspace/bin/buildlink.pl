#!/usr/bin/perl -Wall

##
## Author: Ying Jin
##
## The script is to link streaming files to another location
##
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
my @files = grep {/^file_.*/ || /.*_caption.*.vtt/} readdir(SRCDIR);

foreach my $filename (@files){
    my $symbollink = readlink ("$srcdir/$filename");
 
    my $newsymbollink = "";
    
    if($symbollink =~ /^(..\/)(.*)/){
        $newsymbollink =  $predir.$2;
    }
    print ("ln -s $newsymbollink $descdir/$filename");
    `ln -s  $newsymbollink $descdir/$filename`;

}
close(SRCDIR);

print("DONE\n");
