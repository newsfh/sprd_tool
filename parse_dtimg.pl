#!/usr/bin/perl

$dtimg=$ARGV[0];
$dtc_tool="~/bin/other/dtc";

open(FP1, $dtimg) || die "cannot open file $!";
binmode(FP1);

my $buffer;
my $magic;							# 4
my $version;						# 4
my $dtb_count;						# 4
my $chipset, $platform, $revNum;	# 4
my $master_offset, $dtb_size;		# 4

print "======================================================\n";

printf "Header Info\n";

read(FP1, $buffer, 4);
$magic = unpack("A*", $buffer);
read(FP1, $buffer, 4);
$version = unpack("H8", reverse($buffer));
read(FP1, $buffer, 4);
$dtb_count = unpack("H8", reverse($buffer));

printf "  magic : $magic\n";
printf "  version=0x$version, dtb_count=0x$dtb_count\n";

$count=hex($dtb_count);
for ($i = 0; $i < $count; $i++) {
	read(FP1, $buffer, 4);
	$chipset = unpack("H8", reverse($buffer));
	read(FP1, $buffer, 4);
	$platform = unpack("H8", reverse($buffer));
	read(FP1, $buffer, 4);
	$revNum = unpack("H8", reverse($buffer));
	read(FP1, $buffer, 4);
	$master_offset = unpack("H8", reverse($buffer));
	read(FP1, $buffer, 4);
	$dtb_size = unpack("H8", reverse($buffer));

	printf "  chipset=0x$chipset, platform=0x$platform, revNum=0x$revNum, master_offset=0x$master_offset, dtb_size=0x$dtb_size\n";

	$offset=hex($master_offset);
	$size=hex($dtb_size);
	system("dd if=$dtimg of=dt$i.dtb bs=1 skip=$offset count=$size 2>/dev/null");
	system("$dtc_tool -I dtb -O dts dt$i.dtb > dt$i.dts 2>/dev/null");
	system("rm -rf dt$i.dtb");
}

print "======================================================\n";


close(FP1);
