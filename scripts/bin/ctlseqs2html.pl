#!/usr/bin/env perl
# or /bin/env on some linux distributions, sigh
use Getopt::Long;
use strict;
my $debug = 0;

# brain dump danger.

# $Id: ctlseqs2html.pl,v 1.3 2002/07/23 18:08:14 s_smasch Exp s_smasch $
#
# Program Description: Convert a few ctlseqs of Thomas Dickey's xterm
# (<http://invisible-island.net/xterm/>) into HTML.
#
# Note: you might want to adjust the colors
# and the screen width (if different from 80 characters)

# using the print-action from an xterm with modified resource settings:
#    XTerm.VT100.printAttributes: 2
#    XTerm.VT100.printerCommand: replacement
# with "replacement" being a command in your $PATH that redirects its input
# to a file ("lpr" is the default command).  E.g. you might use an executable
# script containing "cat - > /tmp/xterm.print.$$".
#
# See thread starting with <3c32fd8f.6250759@ID-576.user.dfncis.de> in dcoum.
# Idea about HTML <span> tags and table from Christoph Biedl.
#
# recognize:
#  - CSI Pm m (Pm = 0, 1, 4, 7, 3 x, 4 x, 9 x, 10 x)
#  - SO, SI (alternate char set, with strong limitations)
#  - DECSWL
#  - nothing else yet

# defaults in the following indented parts:

    my $table = 1;
    # 1: HTML 3.2-like table (but with colors)
    # 0: HTML 4.01 <span> tags (sometimes with vertical gaps)

    my $show_alternate = 1;
    # "alternate linedrawing character set",
    #   0: convert to blanks
    #   1: "try" to display.  you'll need an appropriate font and browser.
    #      the first 3 characters (from 15) will definitely be missing.
    #   2: leave them alone, just strip out SI/SO.  results in normal alphabet
    #      characters without sense

    # xterm (certainly) does not print its own default colors and width:

    my $xterm_bgcolor = "black";	# for my old Sun with 66 Hz monitor
    my $xterm_fgcolor = "#ffdd70";	# »wheat«
    my $xterm_width = 80;

    my $html_bgcolor = "gray";
    my $html_fgcolor = "white";

# Colors:
#
#  Either the very original xterm colors
#		black	red3	    green3	yellow3
#		blue3	magenta3    cyan3	gray90
#		gray30	red	    green	yellow
#		blue	magenta     cyan	white
#  if you have pseudocolor, you might have to care about the colormap in
#  your browser (e.g. do not start netscape with "-install").
#  browsers won't recognize color names from rgb.txt, thus:

    my %colors_xterm = (
     '0' => "#000000",  '1' => "#cd0000", '2' => "#00cd00",  '3' => "#cdcd00",
     '4' => "#0000cd",  '5' => "#cd00cd", '6' => "#00cdcd",  '7' => "#e5e5e5",

     '8' => "#4d4d4d",  '9' => "#ff0000", '10' => "#00ff00", '11' => "#ffff00",
     '12' => "#0000ff", '13' => "#ff00ff", '14' => "#00ffff", '15' => "#ffffff",
    );


#  or some HTML colors, they are too dim compared to xterm.  (but these are
#  not necessarily all available, either)

    my %colors_html = (
     '0' => "Black",  '1' => "Maroon", '2' => "Green",  '3' => "Olive",
     '4' => "Navy",  '5' => "Purple", '6' => "Aqua",  '7' => "Silver",

     '8' => "Gray",  '9' => "Red", '10' => "Lime", '11' => "Yellow",
     '12' => "Blue", '13' => "Fuchsia", '14' => "Teal", '15' => "White",
    );

  my %colors = %colors_xterm;

# an empty table header helps for problems in opera-5b1(SunOS)/6tp2(Linux),
# which IMHO renders very "lazy", anyway.  Try cellspacing=2 and
# you might see what i mean.

    my $tableheader = 1;
    my $cellspacing = 0;

# ...end of defaults.


# run time options:

my ($ret, $help, $spantags, $no_tableheader, $html_colors);

$ret = GetOptions (
	"h",			\$help,
	"help",			\$help,
	"width=i",		\$xterm_width,
	"linedrawing=i",	\$show_alternate,
	"fg=s",			\$xterm_fgcolor,
	"bg=s",			\$xterm_bgcolor,
	"spantags",		\$spantags,
	"htmlcolors",		\$html_colors,
	"noheader",		\$no_tableheader,
	"spacing=i",		\$cellspacing,
);

die "Option error." if not $ret;
die "linedrawing must be from [0...2]." if ($show_alternate < 0) or ($show_alternate > 2);
usage() if $help;

%colors = %colors_html if $html_colors;
$table = 0 if $spantags;
$tableheader = 0 if $no_tableheader;


# TODO:
# - fix use of "deprecated" HTML, especially in 4.01 version
# - fix "alternate character set" processing (when activated).
#   currently the browser is assumed to provide an appropriate font
#   (e.g. "-fixed-misc-*") and to actually display the codepoints.
#   the first 3 characters (edges) AFAIK won't get displayed ever.
#   Also, the state of SI/SO is _not_ remembered in here yet.
# - get robust about possible unexpected/invalid control sequences, etc
# - script only knows about "single width/height font" (DECSWL).
# - HTML color "name" comments for the hex colors?

my $csi = '[';	# xterm "control sequence introducer"
my $shiftout = '';	# switch to alternate character set
my $shiftin  = '';	# switch to standard character set
my $decswl = '#5';	# dec single width font

# similarity to "state machine" is my excuse for globals this time.

my $line;		# processing one line at a time
my $part;		# continous plain text between ctlseqs.
my $start = 0;		# start position of a control sequence in a line
my $tmp_start = 0;	# (temporary for above)
my $end = 0;		# end position...
my $next = 0;		# start of a possible next control sequence
my $cntl_str;		# isolated control sequence
my @cntl;		# the single elements of a control sequence
my $attr = 0;		# (number of) character attribute, see ctlseqs.ms

my $fore = 0;		# current state of foreground color
my $back = 0;		# ...background color
my $bold = 0;		# ...bold style
my $underl = 0;		# ...underlined
my $reverse = 0;	# ...inverse/reverse
my $alternate = 0;	# ...alternate character set

# diverse
my $startofline = 1;	# beginning of line? needed for table <tr> tag
my $color = 0;		# the literal color code in a ctlseq
my $sum = 0;		# xterm doesn't print trailing blanks, we have to care
my $pos = 0;		# processing alternate chr set, position of chr
my $char;		# ..., the current character
my $ord = 0;		# ..., ord() 


header();

while (<>) {
    s/$//;		# skip "^M"
    chomp;		# skip newline

    s/${decswl}//g;	# omnipresent, hardcoded deleting.

    printf "\n# LINE: %s\n", $_ if $debug;

    # convert shifted (in/out) parts

    $line = '';
    $pos = 0;
    while (1) {
	$char = substr ($_, $pos, 1);
	last if (length($char) == 0);

	if ($char eq $shiftout) {
	    $alternate = 1;
	    $pos += 1;
	    next;
	} elsif ($char eq $shiftin) {
	    $alternate = 0;
	    $pos += 1;
	    next;
	} elsif ($alternate == 1) {

	    # we are in alternate mode, so do not convert ctlseqs:

	    if ($char eq  '') {
		while (1) {
		    $line .= $char;
		    $pos += 1;
		    last if ($char eq  'm');
		    $char = substr ($_, $pos, 1);
		}
		next;
	    }

	    # what character to print in alternate mode?

	    if ($show_alternate == 1) {
		$ord = ord($char) - 6*16+1;	# look at xfd(1)
		if ($ord > 13 and $ord < 26) {
		    # assumed to be probably printable
		    $char = chr($ord);
		} else {
		    $char = ' '
		}
	    } elsif ($show_alternate == 0) {
		$char = ' ';
	    } # else leave them alone
	}

	$line .= $char;
	$pos += 1;
    }
	
    printf "\n# LINE (no SO/SI): %s\n", $line if $debug;


    # one line at a time
    while (1) {

	if ($table and $startofline) {
	    print '<tr>' . "\n";
	    $startofline= 0;
	}

	# search occurence of a (next) control sequence in a line,

	$tmp_start = index($line, "${csi}", $start);

	# if there was no ctlseq, print the rest of the line--and possible
	# trailing blanks (by calculation)--and then jump out.

	if ($tmp_start eq -1) {
	    my_print(substr($line, $start, length($line)-$start+1));
	    my_print( ' ' x ($xterm_width-$sum) );
	    # my_print( ($xterm_width - $sum) );
	    $bold = 0; $underl = 0; $reverse = 0; $sum = 0;

	    if ($table) {
		print '</tr>';
		$startofline = 1;
	    }
	    last;	# next line
	}

	$start = $tmp_start;

	# there was a ctlseq, find its end.
	# also search for a possible next one and process text up to this one.
	# if there's none, process up to EOL. (but the real EOL detection in
	# code doesn't happen until the next (unsuccesful) search for a ctlseq)

	$end = index($line, "m", $start);
        $next = index($line, "${csi}", $end);

	printf "\n# LEN: %d POS: %d...%d  %d\n", length($line),
		$start, $end, $next if $debug;
	$next = length($line) if ($next == -1 );

	# isolate control sequence, split it into its single parts and
	# iterate over it in a loop.
	#
	# HTML tags must not be folded but xterm folds its control sequences.
	# so open and close the complete set of style attributes around every
	# piece of plain text (avoiding this workaround would mean real work).
	# thus always remember the state of all attributes.

	$cntl_str = substr($line, $start+2, $end-$start-2);
	printf "# CNTL: »%s«\n", $cntl_str if $debug;

	@cntl = split(/;/, $cntl_str);

	$part = substr($line, $end +1, $next - $end - 1);
	printf "# part: %s\n", $part if $debug;

	foreach (@cntl) {

	    # style attributes are one digit long

	    if (length($_) == 1) {
		if ( $_ == "0" ) {
		    $fore = ${xterm_fgcolor};
		    $back = ${xterm_bgcolor};
		    $bold = 0; $underl = 0; $reverse = 0;
		} elsif ( $_ == "1" ) { $bold    = 1; }
		  elsif ( $_ == "4" ) { $underl  = 1; }
		  elsif ( $_ == "7" ) { $reverse = 1;
		}
	    } else {

	    # color attributes are 2 or 3 digits.
	    #
	    # the color codes are the same for the bright colors,
	    # so we have to increase with 8 ourselves, in case.
	    #  3 x : foreground, low eight colors
	    #  9 x : foreground, high
	    #  4 x : foreground, low
	    # 10 x : foreground, high

		$attr = substr($_, 0, length($_)-1);
		printf "# attr: %s\n", $attr if $debug;
		$color = substr($_, length($_)-1, 1);
		printf "# colr: %s\n", $color if $debug;
		if ($attr == "3" or $attr == "9") {
		    $color += 8 if $attr == "9";
		    $fore = $colors{$color};
		} elsif ($attr == "4" or $attr == "10") {
		    $color += 8 if $attr == "10";
		    $back = $colors{$color};
		}
	    }
	} # @cntl

	# print the text itself (and remember line length there), then skip it

	my_print( $part );
	$line = substr($line, $next, length($line)-$next);
	printf "\n# REST: %s\n", $line if $debug;
    }
    print "\n";
    print "\n........\n\n" if $debug;
    $start = 0; $end = 0; $next = 0;
}

footer();



# ---- EOF ----------------



sub header() {
    if ($table) {

	# actually, it's not really 3.2, because this doesn't
	# provide bgcolor attributes in table cells.

	print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">'
	    . "\n";
	print '<!-- no, actually not: contains illegal bgcolor attribute in table cells and illegal characters -->'
	    . "\n";
	print '<HTML> <HEAD> <TITLE>screen shot</TITLE> </HEAD>'
	    . "\n";
	print "<BODY BGCOLOR=${html_bgcolor} TEXT=${html_fgcolor}>\n";
	print '<table border="0" cellspacing="' . $cellspacing
	    . '" cellpadding="0">' . "\n";
	if ($tableheader) {
	    print "<tr>\n";
	    print '<th>&nbsp;</th>' x $xterm_width . "\n";
	    print "</tr>\n";
	}
    } else {
	print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
	    . "\n";
	print '<!-- no, actually not: contains illegal characters -->'
	    . "\n";
	print '<HTML> <HEAD> <TITLE>screen shot</TITLE> </HEAD>'
	    . "\n";
	print "<BODY BGCOLOR=${html_bgcolor} TEXT=${html_fgcolor}>\n";
	print "<PRE>\n";
    }
}

sub my_print($) {
    my $string = $_[0];
    my $length = length($string);
    return if $length eq 0;

    $sum += length($string);

    if ($table) {
	    if (not $reverse) {
		print '<td bgcolor="' . $back . '" colspan="' . $length
		    . '"><tt><font color="' . $fore . '">';
	    } else {
		print '<td bgcolor="' . $fore . '" colspan="' . $length
		    . '"><tt><font color="' . $back . '">';
	    }
	    print '<B>' if $bold;
	    print '<U>' if $underl;

	    print txt2html($string);

	    print '</U>' if $underl;
	    print '</B>' if $bold;
	    print '</font></tt></td>' . "\n";
    } else {
	print "<B>" if $bold;
	print "<U>" if $underl;
	if (not $reverse) {
	    print "<span style=\"color:${fore}; background-color:${back}\">";
	} else {
	    print "<span style=\"color:${back}; background-color:${fore}\">";
	}

	print txt2html($string);

	print "</span>";
	print "</U>" if $underl;
	print "</B>" if $bold;
    }
}

sub txt2html($) {
    $_ = $_[0];
    s/&/&amp;/g;
    s/</&lt;/g;
    s/>/&gt;/g;
    s/ /&nbsp;/g;
    # s/"/&quot;/g;
    return $_;
}
	
sub footer() {
    if ($table) {
	print '</table>';
    } else {
	print '</PRE>';
    }
    print "</BODY></HTML>\n";
}

sub usage() {
    print "\noptions:\n";
    print "  -h[elp]          : this help\n";
    print "  -width <x>       : width of xterm\n";
    print "  -linedrawing <x> : 0 - don't try to show alternate linedrawing characters\n";
    print "                     1 - try to show them\n";
    print "                     2 - show the original plain characters (without sense)\n";
    print "  -fg <color>      : xterm foreground color\n";
    print "  -bg <color>      : xterm background color\n";
    print "  -spantags        : do not use HTML 3.2+ tables but HTML 4.01 <span> tags\n";
    print "  -htmlcolors      : don't use original xterm colors but HTML color names\n";
    print "                     (more dim, though)\n";
    print "  -noheader        : don't insert a table header (opera needs it)\n";
    print "  -spacing         : table cellspacing, to debug bad rendering (e.g. for opera)\n";
    exit(1);
}
