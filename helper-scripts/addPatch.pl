#! /usr/bin/perl -w

# get options
use Getopt::Long;
use List::MoreUtils qw(uniq);

GetOptions("gaf=s" => \$gaf,
	         "patch=s" => \$patch);

if (!(-e $gaf)) {
    die "cannot find ref\n";
}

if (!(-e $patch)) {
    die "cannot find ref\n";
}

# read gaf

open GAF, "<$gaf";
my $junk = <GAF>;
my %gafLine = ();
my %pathName = ();
my %hapmer = ();
my %unused = ();
my %lineHapmer = ();

while (<GAF>) {
  chomp($_);
	my @line = split /\t/, $_;
	
	if (!($line[0] =~ m/unused/)) {
		$gafLine{$line[0]} = $_;
		$lineHapmer{$line[0]} = $line[2];
	}
	
	# remove brackets
	$line[1] =~ s/\[[^\]]*\]//g;
	
	# get utig list
	my @utigs = split /[<>]/, $line[1];
	$junk = shift(@utigs);
	# get other information on the line
	for (my $i = 0; $i <= $#utigs; $i++) {
		if (defined($pathName{$utigs[$i]})) {
			$pathName{$utigs[$i]} .= ";".$line[0];
		} else {
			$pathName{$utigs[$i]} = $line[0];
		}
		
		if (defined($hapmer{$utigs[$i]})) {
			$hapmer{$utigs[$i]} .= ";".$line[2];
		} else {
			$hapmer{$utigs[$i]} = $line[2];
		}
		
		if ($line[0] =~ m/unused/) {
			$unused{$utigs[$i]} = 1;
		} else {
			$unused{$utigs[$i]} = 0;
		}
 	}
	
	# store the current line if it's not an unused utig
	if (!($line[0] =~ m/unused/)) {
		$gafLine{$line[0]} = $_;
	}
}

close (GAF);

# read patch
open PATCH, "<$patch";

while (<PATCH>) {
  chomp($_);

	my @line = split /\t/, $_;
	
	# newly added
	$lineOriginal = $line[1];
	$line[1] =~ s/\[[^\]]*\]//g;
		
	my @lineIDs = split /;/, $line[0];
	my %utigs2process = ();
	my %utigAssign = ();
	my $thisPatchID = $lineIDs[0];

	for (my $i = 0; $i <= $#lineIDs; $i++) {
			
			my @gafLineSplit = split /\t/, $gafLine{$lineIDs[$i]};
			
			$gafLineSplit[1] =~ s/\[[^\]]*\]//g;
			
			my @thisLine = split /[<>]/, $gafLineSplit[1];
			$junk = shift(@thisLine);
			
			for (my $i = 0; $i <= $#thisLine; $i++) {
				
				if (!defined($utigs2process{$thisLine[$i]})) {
					$utigs2process{$thisLine[$i]} = 1;
					$utigAssign{$thisLine[$i]} = $gafLineSplit[2]; # will some utigs get assignment on more than one hapmer?
				}
				
			}
			
			# delete the lines
			delete($gafLine{$lineIDs[$i]});		
	}	
	
	my %newUtigs = ();
	my @splitLine = split /[<>]/, $line[1];
	$junk = shift(@splitLine);
	
	for (my $i = 0; $i <= $#splitLine; $i++) {
		$newUtigs{$splitLine[$i]} = 1;		
	}	
	
	# now process utigs, for anything in %utig2process but not in %newUtigs
	# check if they are part of other path, if not, delete, add a flag to unused
	
	for my $key (keys %utigs2process) {	
	
		if (!defined($newUtigs{$key})) {
		
			my @thisUtigPaths = split /;/, $pathName{$key};
			my $otherPaths = -1;
			for (my $i = 0; $i <= $#thisUtigPaths; $i++) {
				for (my $j = 0; $j <= $#lineIDs; $j++) {		
					if ($thisUtigPaths[$i] eq $lineIDs[$j]) {
						$otherPaths += 1;
					}
				}
			}
			
			if ($otherPaths == $#thisUtigPaths) {		
					$unused{$key} = 1;
					$hapmer{$key} = $utigAssign{$key};
			}	
		}	
	}
	
	# for anything in %newUtigs but unused previously
	# turn the unused off, so they won't be printed.
		
	for my $key (keys %newUtigs) {
		if (!defined($unused{$key})) {
			$unused{$key} = 0;
		} elsif ($unused{$key} == 1) {				
			$unused{$key} = 0;
		} 
	}
	
	# add the line
	$gafLine{$thisPatchID} = $thisPatchID."\t".$lineOriginal."\t".$lineHapmer{$thisPatchID};
	
}

close PATCH;

# now output gaf lines

for my $key (keys %gafLine) {
	
	print $gafLine{$key}, "\n";
	
}

# also output unused utigs

for my $key (keys %unused) {
	
	if ($unused{$key} == 1) {
		if (defined($hapmer{$key})) {
			my @multiPathNames = split /;/, $pathName{$key};
			my @multiHapmers = split /;/, $hapmer{$key};
			for (my $i = 0; $i <= $#multiPathNames; $i++) {
				if ($multiPathNames[$i] =~ m/unused/) {
					print $multiPathNames[$i], "\t>", $key, "\t", $multiHapmers[$i], "\n";
				} else {
					# new unused utig
					print lc($multiHapmers[$i])."_unused_".$key, "\t>", $key, "\t", $multiHapmers[$i], "\n";
				}
			}
		} 
	}
	
}






