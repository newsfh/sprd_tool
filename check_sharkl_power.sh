file_name="/data/power.txt"
time=1

if [ -e /system/bin/sh ]; then
	AWK="busybox awk"
else
	AWK="awk"
fi

function read_reg {
	reg=$1
	len=$2

	lookat -l $len $reg
}

function read_module_eb {
	echo "============  module  ============"
	##### AHB_EB
	read_reg 0x20e00000 1
	##### APB_EB
	read_reg 0x71300000 1
	##### AON_APB_EB0
	##### AON_APB_EB1
	read_reg 0x402e0000 2

	##### CP_SLP_STATUS_DBG0 0x402b0000 0xb4
	##### PWR_STATUS0_DBG 0x402b0000 0xbc
	##### PWR_STATUS1_DBG 0x402b0000 0xc0
	##### PWR_STATUS2_DBG 0x402b0000 0xc4
	##### SLEEP_CTRL 0x402b0000 0xcc
	##### SLEEP_STATUS 0x402b0000 0xd4
	read_reg 0x402b00b4 9
}

function read_clk {
	echo "============  clock  ============"
	cat /d/clk/clk_summary | while read LINE
	do
		count=$(echo $LINE | $AWK '/clk_/{print $2}')
		if [[ $count -ne 0 ]]; then
			echo "$LINE"
		fi
	done
}

function read_ldo {
	echo "============  ldo  ============"
	if [ -n "$1" ]; then
		regdir="/d/sprd-regulator"
		reginfo="enable voltage"
	else
		regdir="/sys/class/regulator"
		reginfo="name min_microvolts max_microvolts microvolts state"
	fi

	reglist=$(ls $regdir)

	for reg in $reglist
	do
		enable=$(cat /d/sprd-regulator/$reg/enable 2>/dev/null)
		if [[ $enable -eq 1 ]]; then
			vol=$(cat /d/sprd-regulator/$reg/voltage)
			echo "--- $reg : $vol"
		fi
#		echo "--- $reg "
#		for info in $reginfo
#		do
#			cat $regdir/$reg/$info 2>/dev/null
#		done
	done
}

function read_ddr_freq {
	echo "============  ddr  ============"
    val=$(lookat 0x30000100)     
    case $val in    
        0x0e0a0d09) freq="192M";;
        0x0f141a11) freq="384M";;
        0x16202b1d) freq="640M";;
        *) freq="unknow";;
    esac
    echo  "ddr: $freq"
}

echo "" > $file_name
while ((1)); do
	echo "" >> $file_name
	echo "~~ $time ~~" >> $file_name
#	echo "~~ $time ~~  $(date)  =====" >> $file_name
	read_module_eb >> $file_name
	read_ddr_freq >> $file_name
	read_clk >> $file_name
	read_ldo "ldo" >> $file_name
	((time+=1))
	sleep 0.5
done
