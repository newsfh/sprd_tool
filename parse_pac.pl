#!/usr/bin/perl

##########################################################################
# author: hua.fang
# date: 2015/11/20
# function: parse pac file
##########################################################################

$pac_img=$ARGV[0];
$log_on=1;

open(FP1, $pac_img) || die "cannot open file $!";
binmode(FP1);

#################### common function
#
sub read_dword {
	my $dword;
	read(FP1, $buffer, 4);
	$dword = unpack("H8", reverse($buffer));
	return $dword
}

sub read_word {
	my $word;
	read(FP1, $buffer, 2);
	$word = unpack("H8", reverse($buffer));
	return $word
}

sub get_string {
	my @string = @_;
	my $count = $#string;
	my $i;
	my $str;

	for ($i=0; $i<$count; $i++) {
		if ($string[$i] != 0 || $string[$i] ne ' ') {
			$str .= $string[$i];
		}
	}

	return $str;
}

sub read_string {
	my @string;
	my $len = $_[0];
	my $str_len = $len/2;

	if ($str_len > 74) {
		$str_len = 74;
	}

	read(FP1, $buffer, $len);
	@string = unpack("(Ax)$str_len", $buffer);

	return &get_string(@string);
}

######################  read header  ####################
#
my $buffer;
my $pac_version;						# 24*2
my $pac_size;							# 4
my $pac_prd_name;						# 256*2
my $pac_prd_version;					# 256*2
my $pac_file_count;						# 4
my $pac_file_offset;					# 4
my $pac_mode;							# 4
my $pac_flash_type;						# 4
my $pac_nand_strategy;					# 4
my $pac_is_nv_backup;					# 4
my $pac_nand_page_type;					# 4
my $pac_prd_alias;						# 100*2
my $pac_oma_dm_product_flag;			# 4
my $pac_is_oma_dm;						# 4
my $pac_is_preload;						# 4
my $pac_reserved;						# 200*4
my $pac_magic;							# 4
my $pac_crc1;							# 2
my $pac_crc2;							# 2

print "======================================================\n";

$pac_version = &read_string(48);
$pac_size = &read_dword;
$pac_prd_name = &read_string(512);
$pac_prd_version = &read_string(512);
$pac_file_count = &read_dword;
$pac_file_offset = &read_dword;
$pac_mode = &read_dword;
$pac_flash_type = &read_dword;
$pac_nand_strategy = &read_dword;
$pac_is_nv_backup = &read_dword;
$pac_nand_page_type = &read_dword;
$pac_prd_alias = &read_string(200);
$pac_oma_dm_product_flag = &read_dword;
$pac_is_oma_dm = &read_dword;
$pac_is_preload = &read_dword;
$pac_reserved = &read_string(800);
$pac_magic = &read_dword;
$pac_crc1 = &read_word;
$pac_crc2 = &read_word;

if ($log_on) {
	printf "-------  Header Info  -------\n";
	printf " version: $pac_version;\n";
	printf " pac size: $pac_size;\n";
	printf " PrdName: $pac_prd_name;\n";
	printf " PrdVersion: $pac_prd_version;\n";
	printf " file count: $pac_file_count;\n";
	printf " file offset: $pac_file_offset;\n";
	printf " mode: $pac_mode;\n";
	printf " flash type: $pac_flash_type;\n";
	printf " nand strategy: $pac_nand_strategy;\n";
	printf " is nv backup: $pac_is_nv_backup;\n";
	printf " nand page type: $pac_nand_page_type;\n";
	printf " PrdAlias: $pac_prd_alias;\n";
	printf " OmaDmProductFlag: $pac_oma_dm_product_flag;\n";
	printf " IsOmaDm: $pac_is_oma_dm;\n";
	printf " is preload: $pac_is_preload;\n";
	printf " reserved: $pac_reserved;\n";
	printf " magic: $pac_magic;\n";
	printf " CRC1: $pac_crc1;\n";
	printf " CRC2: $pac_crc2;\n";
}

######################  read file  ####################
#
my $file_size;						# 4
my $file_file_id;					# 256*2
my $file_file_name;					# 256*2
my $file_file_version;				# 256*2
my $file_file_size;					# 4
my $file_file_flag;					# 4
my $file_check_flag;				# 4
my $file_data_offset;				# 4
my $file_cam_omit_flag;				# 4
my $file_addr_num;					# 4
my $file_addr;						# 4*5
my $file_reserved;					# 249*4

sub cp_file {
	my $file_name = "pac_".$_[0];
	my $file_offset = hex($_[1]);
	my $file_size = hex($_[2]);
	my $offset_start=0;
	my $offset_end=0;
	my $offset=0;
	my $offset_len=0;
	my $step = 1024;

	if ($file_size == 0) {
		return;
	}

	while (-e $file_name) {
		$file_name = $file_name."1";
	}

#	if ($file_offset>$step*1024 && $file_size>$step*1024) {
#		$step *= 1024;
#	}

	$offset_start = ($file_offset % $step);
	$offset_end = (($file_offset+$file_size) % $step);

	if ($offset_start != 0) {
		$offset_len = ($step - $offset_start);
		system("dd if=$pac_img of=mypacparse_temp0_$file_name bs=1 skip=$file_offset count=$offset_len 2>/dev/null");
	}

	if ($offset_end != 0) {
		$offset = $file_offset+$file_size - $offset_end;
		system("dd if=$pac_img of=mypacparse_temp2_$file_name bs=1 skip=$offset count=$offset_end 2>/dev/null");
	}

	if ($offset_len+$offset_end != $file_size) {
		$offset=($file_offset+$offset_len)/$step;
		$offset_len=($file_size - $offset_len - $offset_end)/$step;
		#system("dd if=$pac_img of=mypacparse_temp1_$file_name bs=$step skip=$offset count=$offset_len");
		system("dd if=$pac_img of=mypacparse_temp1_$file_name bs=$step skip=$offset count=$offset_len 2>/dev/null");
	}

	system("cat mypacparse_temp* > $file_name");
	system("rm -rf mypacparse_temp*");
}

$count=hex($pac_file_count);
for ($i = 0; $i < $count; $i++) {
	$file_size = &read_dword;
	$file_file_id = &read_string(512);
	$file_file_name = &read_string(512);
	$file_file_version = &read_string(512);
	$file_file_size = &read_dword;
	$file_file_flag = &read_dword;
	$file_check_flag = &read_dword;
	$file_data_offset = &read_dword;
	$file_cam_omit_flag = &read_dword;
	$file_addr_num = &read_dword;
	$file_addr = &read_string(20);
	$file_reserved = &read_string(249*4);

	if ($log_on) {
		printf "-------  file $i  -------\n";
		printf " struct size: $file_size;\n";
		printf " file id: $file_file_id;\n";
		printf " file name: $file_file_name;\n";
		printf " file version: $file_file_version;\n";
		printf " file size: $file_file_size; 	%d\n", hex($file_file_size);
		printf " file flag: $file_file_flag;\n";
		printf " check flag: $file_check_flag;\n";
		printf " data offset: $file_data_offset;	%d\n", hex($file_data_offset);
		printf " can omit flag: $file_cam_omit_flag;\n";
		printf " addr num: $file_addr_num;\n";
		printf " addr: $file_addr;\n";
		printf " reserved: $file_reserved;\n";
	}

	&cp_file($file_file_name, $file_data_offset, $file_file_size);
#	exit;
}

print "======================================================\n";


close(FP1);
