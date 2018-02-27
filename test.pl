#! /usr/bin/perl -w
# Give an argument to use stdin, stdout instead of console
# If argument starts with /dev, use it as console
# If argument is '--no-print', do not print the result.

require 5.006;
BEGIN{ $ENV{PERL_RL} = 'TTYtter' };	# Do not test TR::Gnu !
use Term::ReadLine;

use Carp;
$SIG{__WARN__} = sub { warn Carp::longmess(@_) };

open(IN, '<', './t/input.txt') or die "Can't open input.txt, $@, $!";
$term = Term::ReadLine->new('Simple Perl calc', \*IN, \*STDOUT);

$prompt = "Enter arithmetic or Perl expression: ";
if ((my $l = $ENV{PERL_RL_TEST_PROMPT_MINLEN} || 0) > length $prompt) {
  $prompt =~ s/(?=:)/ ' ' x ($l - length $prompt)/e;
}
$OUT = $term->OUT || STDOUT;
$IN = $term->IN || STDIN;
binmode($OUT, ":utf8");
binmode($IN, ":utf8");
our $dont_use_counter = 0;
our $ansi = 1;
$term->hook_no_counter;
$term->hook_use_ansi;

%features = %{ $term->Features };
if (%features) {
  @f = %features;
  print $OUT "Features present: @f\n";
  #$term->ornaments(1) if $features{ornaments};
} else {
  print $OUT "No additional features present.\n";
}
print $OUT "\n  Flipping rl_default_selected each line.\n";
print $OUT <<EOP;

	Hint: Entering the word
		exit
	would exit the test. ;-)  (If feature 'preput' is present,
	this word should be already entered.)

EOP
while ( defined ($_ = $term->readline($prompt)) ) {
  $res = eval($_);
  warn $@ if $@;
  print $OUT $res, "\n" unless $@ or $no_print;
  $term->addhistory($_) if /\S/ and !$features{autohistory};
  $readline::rl_default_selected = !$readline::rl_default_selected;
}
