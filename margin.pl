#!/usr/bin/perl

# $Id: margin.pl,v 1.8 2011/02/19 19:09:54 micro Exp $
# script to scrape the IB margin page and create a file for use with
# buttontrader
#
use warnings;
use strict;

use autodie;
use version; our $VERSION = qv('1.0.0');
use English qw(-no_match_vars);
use HTML::TableExtract;
use LWP::UserAgent;
use POSIX qw(strftime);
use Carp;

my $prog = $PROGRAM_NAME;
my $home = $ENV{HOME};

my $url = 'http://interactivebrokers.com/en/p.php?f=margin';
my $accept =
'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5';
my $out_dir  = $home . '/margin';
my $out_file = $out_dir . '/margin.stm-########';

# get today's date (for file extension
my $date = strftime '%d%m%Y', localtime;
$out_file =~ s/\#\#\#\#\#\#\#\#/$date/xms;

my $ua = LWP::UserAgent->new;
my $res = $ua->get($url, 'Accept:' => $accept);

# Check the outcome of the response
croak $res->status_line if ($res->is_error);

my $te = HTML::TableExtract->new(
  headers => [
    'Exchange',
    'IB Underlying',
    'Product description',
    'Trading Class',
    'Intraday Initial',
    'Intraday Maintenance',
    'Overnight Initial',
    'Overnight Maintenance',
    'Currency'
  ]
);

$te->parse($res->content);

# Open file to write results
open my $fh, '>', $out_file
  or croak "$prog: cannot open $out_file: $OS_ERROR\n";

# Examine all matching tables
foreach my $ts ($te->tables) {

  #print "Table (", join(',', $ts->coords), "):\n";
  foreach my $row ($ts->rows) {
    print {$fh} join('; ', @{$row}), "; \r\n"
      or croak "$prog: cannot write to $out_file: $OS_ERROR\n";
  }
}

close $fh or croak "$prog: cannot close $out_file: $OS_ERROR\n";
exit 0;

# vim: set et ts=2 sw=2 ai invlist si cul nu:
