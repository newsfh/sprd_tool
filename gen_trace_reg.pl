#!/usr/bin/perl

##########################################################################
# author: hua.fang
# date: 2015/11/30
# function: generate register list from kernel log
# 			gen_trace_reg.pl log_xxxx.lst
##########################################################################

if ($#ARGV < 0 ) {
	die "param wrong!\n";
}

$file1=$ARGV[0];
open(FP, $file1) || die "cannot open file $!";

$is_new=0;
$line_no=1;
$count=0;

while(defined($line = <FP>)) {
	if ($line =~ /pc\s*:\s*\[\<(\w{8})\>\]\s*lr\s*:\s*\[\<(\w{8})\>\]\s*psr:\s*(\w{8})/) {
		printf "~~~~~~~~  $count  ~~~~~~~~\n";
		$count++;
		printf "r.set cpsr 0x$3\nr.set pc 0x$1\nr.set r14 0x$2\n";
	} elsif ($line =~ /sp\s*:\s*(\w{8})\s*ip\s*:\s*(\w{8})\s*fp\s*:\s*(\w{8})/) {
		printf "r.set r13 0x$1\nr.set r12 0x$2\nr.set r11 0x$3\n";
	} elsif ($line =~ /r10\s*:\s*(\w{8})\s*r9\s*:\s*(\w{8})\s*r8\s*:\s*(\w{8})/) {
		printf "r.set r10 0x$1\nr.set r9 0x$2\nr.set r8 0x$3\n\n";
	} elsif ($line =~ /r7\s*:\s*(\w{8})\s*r6\s*:\s*(\w{8})\s*r5\s*:\s*(\w{8})\s*r4\s*:\s*(\w{8})/) {
		printf "r.set r7 0x$1\nr.set r6 0x$2\nr.set r5 0x$3\nr.set r4 0x$4\n";
	} elsif ($line =~ /r3\s*:\s*(\w{8})\s*r2\s*:\s*(\w{8})\s*r1\s*:\s*(\w{8})\s*r0\s*:\s*(\w{8})/) {
		printf "r.set r3 0x$1\nr.set r2 0x$2\nr.set r1 0x$3\nr.set r0 0x$4\n\n";
	} else {
		$is_new=1;
	}
	$line_no++;
}


close(FP1);
