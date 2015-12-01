#!/usr/bin/perl

##########################################################################
# author: hua.fang
# date: 2015/10/20
# function: parse kernel text section
##########################################################################

if ($#ARGV < 1 ) {
	die "param wrong!\n File should be dump_txt.mem and vmlinux_txt.mem";
}

$file1=$ARGV[0]; #"/home/likewise-open/SPREADTRUM/hua.fang/net_folder/to_internal_folder/Platform/hua.fang/dump41/dump.txt";
$file2=$ARGV[1]; #"/home/likewise-open/SPREADTRUM/hua.fang/net_folder/to_internal_folder/Platform/hua.fang/dump41/vmlinux.txt";
$text_base_info=$ARGV[2];
$is_armv8=$ARGV[3];  # check whether it is armv8, default is no.

open(FP1, $file1) || die "cannot open file $!";
binmode(FP1);

open(FP2, $file2) || die "cannot open file $!";
binmode(FP2);

open(TMPFP1, ">dump_sysdump_text.tmp") || die "cannot open file $!";
binmode(TMPFP1);

open(TMPFP2, ">dump_vmlinux_text.tmp") || die "cannot open file $!";
binmode(TMPFP2);
       
my $buffer1;
my $i=0;
my $text_base=hex($text_base_info);
my $is_text_format=0;


if ("$is_text_format" eq "1") {
	$cmp_armv8_1="d503201f";
	$cmp_1="e8bd4000";
} else {
	$cmp_armv8_1="1f2003d5";
	$cmp_1="0040bde8";
}

print "======================================================\n";
print "text off   | sysdump  vmlinux\n";
print "-----------|--------------------\n";

while(read(FP1, $buffer1, 4) && read(FP2, $buffer2, 4)) {
	if ("$is_text_format" eq "1") {
		$hex1 = unpack("H*", reverse($buffer1));
		$hex2 = unpack("H*", reverse($buffer2));
	} else {
		$hex1 = unpack("H*", $buffer1);
		$hex2 = unpack("H*", $buffer2);
	}

	if ("$hex1" eq "$hex2") {
		syswrite(TMPFP1, $buffer1, length($buffer1));
		syswrite(TMPFP2, $buffer2, length($buffer2));
	}
	else {
		if ("$is_armv8" ne "armv8" && "$hex1" eq "$cmp_1") {
			syswrite(TMPFP1, $buffer1, length($buffer1));
			syswrite(TMPFP2, $buffer1, length($buffer1));
		}
		elsif ("$is_armv8" eq "armv8" && "$hex1" eq "$cmp_armv8_1") {
			syswrite(TMPFP1, $buffer1, length($buffer1));
			syswrite(TMPFP2, $buffer1, length($buffer1));
		}
#		elsif ("$is_armv8" ne "armv8" && "$hex2" eq "00f020e3") {  ##  nop instruction in vmlinux
#			syswrite(TMPFP1, $buffer1, length($buffer1));
#			syswrite(TMPFP2, $buffer1, length($buffer1));
#		}
		else {
			if ("$is_armv8" eq "armv8") {
				printf "0x%16x | ", $text_base+$i;
			}
			else {
				printf "0x%08x | ", $text_base+$i;
			}
			print "$hex1 $hex2\n";

			syswrite(TMPFP1, $buffer1, length($buffer1));
			syswrite(TMPFP2, $buffer2, length($buffer2));
		}
	}
	$i+=4;
}

print "-----------|--------------------\n";
print "text off   | sysdump  vmlinux\n";
print "======================================================\n";
print "dump to dump_sysdump_text.tmp and dump_vmlinux_text.tmp OK!\n";

close(FP1);
close(FP2);
close(TMPFP1);
close(TMPFP2);
