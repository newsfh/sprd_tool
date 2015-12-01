#!/system/bin/sh

##########################################################################
# author: hua.fang
# date: 2015/10/20
# function: dump ddr freq according to ddr config
##########################################################################

echo "DDR freq :" > /data/ddr_freq.txt
i=0

while ((1)); do
	val=$(lookat 0x30000100)                      
	case $val in                       
		0x0e0a0d09) freq="192M";;
		0x0f141a11) freq="384M";;
		0x16202b1d) freq="640M";;
		*) freq="unknow";;
	esac
	echo  "$i $freq" >> /data/ddr_freq.txt
	i=$((i+1))
	sleep 0.2
done

