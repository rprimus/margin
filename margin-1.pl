#!/usr/bin/perl

# $Id: margin.pl,v 1.6 2010/09/09 07:24:48 micro Exp $
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

my $prog = $PROGRAM_NAME;

my $url='http://interactivebrokers.com/en/p.php?f=margin';
my $accept='text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5';
my $out_dir = '/usr/local/micro/margin';
my $out_file = $out_dir . '/margin.stm-########';
my @headers = ('Exchange', 'IB Underlying', 'Product description', 'Trading Class', 'Intraday Initial', 'Intraday Maintenance', 'Overnight Initial', 'Overnight Maintenance', 'Currency');

# get today's date (for file extension
my $date = strftime '%d%m%Y', localtime;
$out_file =~ s/\#\#\#\#\#\#\#\#/$date/xms;

my $te = HTML::TableExtract->new( headers => \@headers );

process_tables(open_file($out_file), get_content($url), $te);
exit 0;


sub get_content {
	my ($uri) = @_;

  my $ua = LWP::UserAgent->new;
  my $res=$ua->get($uri, 'Accept:' => $accept);

  #Check the outcome of the response
  croak $res->status_line if ($res->is_error);
  return \$res->content;
}

sub open_file {
	my ($file) = @_;

  open my $fh, '>', $file or croak "$prog: open_file: cannot open $file: $OS_ERROR\n";
  return $fh;
}

sub process_tables {
  my ($fh, $content, $table) = @_;
  $te->parse(${$content});

  #Examine all matching tables
  foreach my $ts ($table->tables) {
      print {$fh} map {join('; ', @{$_}), "; \r\n"} $ts->rows or croak "$prog: cannot write to file: $OS_ERROR";
  }
  close $fh;
  return;
}

# vim: set et ts=2 sw=2 ai invlist si cul nu:
