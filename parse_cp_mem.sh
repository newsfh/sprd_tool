
##########################################################################
# author: hua.fang
# date: 2015/9/20
# function: parse cp memory layout
##########################################################################

function read_cpmem() {
cat << EOF
CP 0x09600000+0x80000000 0x04200000
fixnv 0x8AA42000 0x0006C000
runnv 0x8AA42000+0x0006C000 0x00090000
modem 0x8AB48000 0x00C00000
ldsp 0x89900000 0x00b00000
gdsp 0x89600000+0x20000 0x002E0000
warm 0x8D080000 0x00200000
EOF
}

echo "module  |     start     |     end     |     size     |"
echo "--------|---------------|-------------|--------------|"
read_cpmem | while read LINE 
do
	name=$(echo $LINE | awk '{print $1}')
	start=$(echo $LINE | awk '{print $2}')
	size=$(echo $LINE | awk '{print $3}')

	end=$(($start+$size))
	((start=$start))
	printf "$name  \t  0x%08x  \t  0x%08x  \t  0x%08x\n" $start $end $size
done | sort -k 2
