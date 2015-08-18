#!/usr/bin/perl

if (! open MYFILE, $ARGV[0]) {
	die "can not open file $ARGV[0]";
}

$total_mem;

sub cal_mem_size {
	my $mem_size = $_[0];
	my $format;

	if (length($mem_size) > 6) {
		$format = sprintf "%0.2f M", $mem_size/1024/1024;
	} elsif (length($mem_size) > 3) {
		$format = sprintf "%0.2f K", $mem_size/1024;
	} else {
		$format = sprintf "%0.2f B", $mem_size;
	}

	return $format;
}

while (<MYFILE>) {
	chomp;
	if (/0x(\w{8,16})..0x(\w{8,16})/i) {
		$total_mem += (hex($2) - hex($1) + 1);
		printf "$_   - %s\n", &cal_mem_size(hex($2) - hex($1) + 1);
	}
}

print "---------\n";
printf "total mem: %d(%s)\n", $total_mem, &cal_mem_size($total_mem);

