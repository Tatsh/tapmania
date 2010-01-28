#!/usr/bin/perl

use constant {
	NONE 		=> 0,
	SECTION		=> 1,
	COMMON_SECTION	=> 2
};

my %pages;
my %common;

my $state = NONE;
my $curPage = "";

sub grabCommon {
	my ($line, $name) = (shift, shift);
	if($line =~ m/$name\s*=\s*(\d+)/) {
		$common{$name} = $1;	
		print "Set '$name' to '$1'\n";
	}
}

# Check sufficient args count
@ARGV == 2 or print("Usage: tapfont.pl original.ini converted.plist\n") and die();

# Open original ini file
open(F, $ARGV[0]) or die("Can't open ini file at path: '".$ARGV[0]."'\n");

while($line = <F>) {
	$line =~ s/#.*$//;
	$line =~ s/(.*)(\r)$/$1/;
	chomp($line);

	if($line =~ /^\s+$/ || length($line)==0) {
		next;
	}

	if($line =~ m/\[(.*)\]/) {
		$state = SECTION;
		$curPage = $1;
		$curPage =~ s/\s//;
		print "Detected section with name '$curPage'\n";
		
		if($curPage eq "common") {
			print "It's the common section. Read common settings here...\n";
			$state = COMMON_SECTION;

		} else {
			$pages{$curPage} = ();
		}
	}
	elsif($state == COMMON_SECTION) {
		grabCommon($line, 'Baseline');
		grabCommon($line, 'Top');
		grabCommon($line, 'LineSpacing');
		grabCommon($line, 'ScaleAllWidthsBy');
		grabCommon($line, 'DrawExtraPixelsLeft');
		grabCommon($line, 'DrawExtraPixelsRight');
		grabCommon($line, 'AdvanceExtraPixels');
		grabCommon($line, 'AddToAllWidths');
		grabCommon($line, 'AddToAllHeights');
	}
	elsif($state == SECTION) {
		if($line =~ /^Line\s+(\d+)=(.*)/) {
			$line = "line $1=$2";
		}

		push(@{$pages{$curPage}}, $line);
	}
}

# Close the ini file
close(F);

# Open the output file
$plist = $ARGV[1];

open(F, ">$plist") or die("Can't open '$plist' for writing.\n");
print "Dumping gathered font info into plist...\n";

# add default header
print(F <<PLISTEND 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
PLISTEND
);

### print what we have to the plist file
foreach(keys %common) {
	print F "\t<key>$_</key>\n\t<integer>$common{$_}</integer>\n\n";
}

print F "\t<key>pages</key>\n\t<dict>\n";
foreach(sort keys %pages) {
	print F "\t\t<key>$_</key>\n";
	print F "\t\t<array>\n";	

	foreach(@{$pages{$_}}) {
		print F "\t\t\t<string>$_</string>\n";
	}	
	
	print F "\t\t</array>\n";	
}

print F "\t</dict>\n";	

# add default footer
print(F <<PLISTEND 
</dict>
</plist>
PLISTEND
);

# Close our plist file
close(F);

print "Success.\n";
