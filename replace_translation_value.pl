#!/usr/bin/perl

use strict;
use Data::Dumper;

#if($#ARGV != 2) {
#    print STDERR "You must specify exactly two arguments.\n";
#	exit ;
#}

my $date=`date +%Y%m%d`;
chomp($date);

my %trans;
my %trans2;
my @trans_arr;
my @trans_arr2;
my @result;
my $filename=$ARGV[2];

@trans_arr  = readFile(\%trans , $ARGV[0]);
@trans_arr2 = readFile(\%trans2 , $ARGV[1]);
@result = compare(\@trans_arr, \@trans_arr2);

my $outfile = $filename.'_'.$date;

open (FILE, ">> $outfile") || die "problem opening $outfile\n";

foreach my $hash_ref (@result){
    foreach (keys $hash_ref) {
	
			my $okey = $_ ;
			my $ovalue = ${$hash_ref}{$_};
			
			if(!defined $ovalue|| $ovalue eq ''){
				print FILE "\n";
			}else{
				print FILE $okey."=".$ovalue."\n";
	     	}
	}
}
close(FILE);

sub compare
{
	my($arr1, $arr2) = @_;
	 
	foreach my $hash_ref (@{$arr1}) {
    	foreach (keys $hash_ref) {
			
			my $okey = $_ ;
			my $ovalue = ${$hash_ref}{$_};
			chomp($okey);
			chomp($ovalue);

#			print "$okey => $ovalue\n";
			foreach my $hash_ref2 (@{$arr2})
			{
				foreach (keys $hash_ref2){
				 	my $nkey = $_;
					my $nvalue = ${$hash_ref2}{$_};

					if($nkey eq $okey ){	
						$ovalue=$nvalue;
						#print "$ovalue";
					}
				}
			}
			$hash_ref->{$okey}=$ovalue;
		}
	}

	return @{$arr1};
}

sub readFile
{
	my ($trans, $file) = @_;
	my @seg;
 	my @tmp;

 	open(FH1, '<', $file) or die "Failed to read $file\n";
	while(my $line = <FH1>)
 	{
		chomp($line);
		@seg = split(/=/, $line);
	    $seg[0] =~ s/^\s+|\s+$//g;
	    $seg[1] =~ s/^\s+|\s+$//g;
		$trans = {};
 	
		my ($key, $value) = ($seg[0], $seg[1]);
		#print "$key\t$value\n";
		$trans->{$key}= $value;
		push @tmp, $trans;
	}

	print Dumper($trans);
	
	close(FH);
	return @tmp;
}
