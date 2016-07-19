#!/bin/bash

##########################################################################
# author: hua.fang
# date: 2016/6/20
# function: split sipc info from memory
##########################################################################

########################   information
### smem info
smem_addr=87800000
smem_len=500000
smem_file="smem-0x$smem_addr++0x$smem_len.dat"

### smsg info
smsg_addr=8AA40000
smsg_len=1000
smsg_file="smsg-0x$smsg_addr++0x$smsg_len.dat"

#########################   help
filename=$(basename $0)

function help() {
	echo "$filename <ap_ramdump>"
}

#########################   translation
function dump_sipc_data() {
    file_name=$1
	base_unit=4096
	mem_addr_oct=$(echo "obase=10; ibase=16; 80000000"|bc);

	smem_addr_oct=$(echo "obase=10; ibase=16; $smem_addr"|bc);
	smem_len_oct=$(echo "obase=10; ibase=16; $smem_len"|bc);
	smem_skip=$((($smem_addr_oct-$mem_addr_oct)/$base_unit));
	smem_count=$(($smem_len_oct/$base_unit));
	dd if=$file_name of=$smem_file bs=$base_unit skip=$smem_skip count=$smem_count

	smsg_addr_oct=$(echo "obase=10; ibase=16; $smsg_addr"|bc);
	smsg_len_oct=$(echo "obase=10; ibase=16; $smsg_len"|bc);
	smsg_skip=$((($smsg_addr_oct-$mem_addr_oct)/$base_unit));
	smsg_count=$(($smsg_len_oct/$base_unit));
	dd if=$file_name of=$smsg_file bs=$base_unit skip=$smsg_skip count=$smsg_count
}

if [[ -n "$1" && -e $1 ]]; then
    dump_sipc_data $1
else
    help
fi
