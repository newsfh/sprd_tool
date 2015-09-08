#!/bin/sh

filename=$(basename $0)
message()
{
	echo "  $filename <sysdump_file> [armv8]"
}

if [ $# -lt 1 ]; then
	echo "param number error!"
	message;
	exit
fi

if [ ! -e $1 ]; then
	echo "sysdump files not exist!"
	message;
	exit
fi

if [ ! -e "vmlinux" ]; then
	echo "vmlinux not exist!"
	message;
	exit
fi

if [ "$2" = "armv8" ]; then
	text_offset_info=$(aarch64-linux-android-readelf -S vmlinux | grep " .text ");

	text_base=$(echo $text_offset_info | awk '{print $5}' | tr a-z A-Z);
	text_offset=$(echo $text_offset_info | awk '{print $6}' | tr a-z A-Z);
	dump_text_offset="81000";		# text section offset in dump file

	text_size_info=$(aarch64-linux-android-readelf -S vmlinux | grep "AX       0     0     4096");
	text_size=$(echo $text_size_info | awk '{print $1}' | tr a-z A-Z);
else
	text_offset_info=$(readelf -S vmlinux | grep " .text ");

	text_base=$(echo $text_offset_info | awk '{print $5}' | tr a-z A-Z);
	text_offset=$(echo $text_offset_info | awk '{print $6}' | tr a-z A-Z);
	dump_text_offset=$text_offset;	# text section offset in dump file

	text_size_info=$(readelf -S vmlinux | grep " .text ");
	text_size=$(echo $text_size_info | awk '{print $7}' | tr a-z A-Z);
fi

dump_text_off=$(echo "obase=10; ibase=16; $dump_text_offset"|bc);
text_off=$(echo "obase=10; ibase=16; $text_offset"|bc);
text_sz=$(echo "obase=10; ibase=16; $text_size"|bc);

dd if=$1 of=dump_txt_tmp.tmp bs=4 skip=$(($dump_text_off/4)) count=$(($text_sz/4))
dd if=vmlinux of=vmlinux_txt_tmp.tmp bs=4 skip=$(($text_off/4)) count=$(($text_sz/4))

parse_text.pl dump_txt_tmp.tmp vmlinux_txt_tmp.tmp $text_base "$2"

echo "text base: 0x$text_base"

rm -rf dump_txt_tmp.tmp vmlinux_txt_tmp.tmp

exit

