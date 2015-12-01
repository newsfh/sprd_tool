##########################################################################
# author: hua.fang
# date: 2015/6/30
# function: check sharkl pinmap
##########################################################################

function hex() {
	printf "0x%08x" $1
}

function hex1() {
	printf "0x%02x" $1
}

function hex3() {
	printf "0x%02x" $1
}

function hex4() {
	printf "0x%02x" $1
}

function hex7() {
	printf "0x%02x" $1
}

function read_reg() {
	adb shell lookat $(hex $(($1 + $2))) | sed 's/\r$//'
}

function bin_hex() {
	value=$1
	vshift=$2
	vmask=$3
	echo -n $(`expr hex$vmask` $(($value >> $vshift & $vmask)))
}

function print_bit() {
	reg_val=$1
	reg_bit=$2
	info=$3

	echo -n "[$reg_bit]"
	case `bin_hex $reg_val $reg_bit 1` in
		0x00) echo " //$info" ;;
		0x01) echo " $info" ;;
	esac
}

function show_pininfo() {
cat << EOF
0x402a0000 PIN_CTRL_REG0
0x402a0004 PIN_CTRL_REG1
0x402a0008 PIN_CTRL_REG2
0x402a000c PIN_CTRL_REG3
0x402a0010 PIN_CTRL_REG4
0x402a0014 PIN_CTRL_REG5
0x402a0018 Reserved
0x402a001c Reserved
0x402a0020 RFSDA0 gpio1
0x402a0024 RFSCK0 gpio2
0x402a0028 RFSEN0 gpio3
0x402a002c RFSDA1 gpio4
0x402a0030 RFSCK1 gpio5
0x402a0034 RFSEN1 gpio6
0x402a0038 RFCTL15 gpio7
0x402a003c RFCTL16 gpio8
0x402a0040 RFCTL17 gpio9
0x402a0044 RFCTL18 gpio10
0x402a0048 RFCTL19 gpio11
0x402a004c RFCTL20 gpio12
0x402a0050 RFCTL21 gpio13
0x402a0054 RFCTL22 gpio14
0x402a0058 RFCTL23 gpio15
0x402a005c RFCTL24 gpio16
0x402a0060 RFCTL25 gpio17
0x402a0064 RFCTL26 gpio18
0x402a0068 RFCTL0 gpio19
0x402a006c RFCTL1 gpio20
0x402a0070 RFCTL2 gpio21
0x402a0074 RFCTL3 gpio22
0x402a0078 RFCTL4 gpio23
0x402a007c RFCTL5 gpio24
0x402a0080 RFCTL6 gpio25
0x402a0084 RFCTL7 gpio26
0x402a0088 RFCTL8 gpio27
0x402a008c RFCTL9 gpio28
0x402a0090 RFCTL10 gpio29
0x402a0094 RFCTL11 gpio30
0x402a0098 RFCTL12 gpio31
0x402a009c RFCTL13 gpio32
0x402a00a0 RFCTL14 gpio33
0x402a00a4 RFCTL27 gpio34
0x402a00a8 XTL_EN gpio35
0x402a00ac RFFE_SCK0 gpio36
0x402a00b0 RFFE_SDA0 gpio37
0x402a00b4 RFCTL28 gpio38
0x402a00b8 RFCTL29 gpio39
0x402a00bc SIMCLK0 gpio157
0x402a00c0 SIMDA0 gpio158
0x402a00c4 SIMRST0 gpio159
0x402a00c8 SIMCLK1 gpio160
0x402a00cc SIMDA1 gpio161
0x402a00d0 SIMRST1 gpio162
0x402a00d4 SIMCLK2 gpio154
0x402a00d8 SIMDA2 gpio155
0x402a00dc SIMRST2 gpio156
0x402a00e0 SD0_D3 gpio148
0x402a00e4 SD0_D2 gpio149
0x402a00e8 SD0_CMD gpio150
0x402a00ec SD0_D0 gpio151
0x402a00f0 SD0_D1 gpio152
0x402a00f4 SD0_CLK0 gpio153
0x402a00f8 SD1_CLK gpio64
0x402a00fc SD1_CMD gpio65
0x402a0100 SD1_D0 gpio66
0x402a0104 SD1_D1 gpio67
0x402a0108 SD1_D2 gpio68
0x402a010c SD1_D3 gpio69
0x402a0110 IIS0DI gpio56
0x402a0114 IIS0DO gpio57
0x402a0118 IIS0CLK gpio58
0x402a011c IIS0LRCK gpio59
0x402a0120 U0TXD gpio60
0x402a0124 U0RXD gpio61
0x402a0128 U0CTS gpio62
0x402a012c U0RTS gpio63
0x402a0130 PTEST
0x402a0134 ANA_INT
0x402a0138 EXT_RST_B
0x402a013c CHIP_SLEEP
0x402a0140 XTL_BUF_EN0
0x402a0144 XTL_BUF_EN1
0x402a0148 CLK_32K
0x402a014c AUD_SCLK
0x402a0150 AUD_ADD0
0x402a0154 AUD_ADSYNC
0x402a0158 AUD_DAD1
0x402a015c AUD_DAD0
0x402a0160 AUD_DASYNC
0x402a0164 ADI_D
0x402a0168 ADI_SYNC
0x402a016c ADI_SCLK
0x402a0170 LCM_RSTN gpio50
0x402a0174 DSI_TE gpio51
0x402a0178 MTDO_ARM gpio80
0x402a017c MTDI_ARM gpio81
0x402a0180 MTCK_ARM gpio82
0x402a0184 MTMS_ARM gpio83
0x402a0188 MTRST_N_ARM gpio84
0x402a018c DTDO_LTE gpio85
0x402a0190 DTDI_LTE gpio86
0x402a0194 DTCK_LTE gpio87
0x402a0198 DTMS_LTE gpio88
0x402a019c DRTCK_LTE gpio89
0x402a01a0 NFWPN gpio98
0x402a01a4 NFRB gpio99
0x402a01a8 NFCLE gpio100
0x402a01ac NFALE gpio101
0x402a01b0 NFREN gpio102
0x402a01b4 NFD4 gpio103
0x402a01b8 NFD5 gpio104
0x402a01bc NFD6 gpio105
0x402a01c0 NFD7 gpio106
0x402a01c4 NFD10 gpio107
0x402a01c8 NFD11 gpio108
0x402a01cc NFD14 gpio109
0x402a01d0 NFCEN0 gpio110
0x402a01d4 NFWEN gpio111
0x402a01d8 NFD0 gpio112
0x402a01dc NFD1 gpio113
0x402a01e0 NFD2 gpio114
0x402a01e4 NFD3 gpio115
0x402a01e8 NFD8 gpio116
0x402a01ec NFD9 gpio117
0x402a01f0 NFD12 gpio118
0x402a01f4 NFD13 gpio119
0x402a01f8 NFD15 gpio120
0x402a01fc CCIRD0 gpio40
0x402a0200 CCIRD1 gpio41
0x402a0204 CMMCLK gpio42
0x402a0208 CMPCLK gpio43
0x402a020c CMRST0 gpio44
0x402a0210 CMRST1 gpio45
0x402a0214 CMPD0 gpio46
0x402a0218 CMPD1 gpio47
0x402a021c SCL0 gpio48
0x402a0220 SDA0 gpio49
0x402a0224 SPI2_CSN gpio52
0x402a0228 SPI2_DO gpio53
0x402a022c SPI2_DI gpio54
0x402a0230 SPI2_CLK gpio55
0x402a0234 SPI0_CSN gpio90
0x402a0238 SPI0_DO gpio91
0x402a023c SPI0_DI gpio92
0x402a0240 SPI0_CLK gpio93
0x402a0244 MEMS_MIC_CLK0 gpio94
0x402a0248 MEMS_MIC_DATA0 gpio95
0x402a024c MEMS_MIC_CLK1 gpio96
0x402a0250 MEMS_MIC_DATA1 gpio97
0x402a0254 KEYOUT0 gpio121
0x402a0258 KEYOUT1 gpio122
0x402a025c KEYOUT2 gpio123
0x402a0260 KEYIN0 gpio124
0x402a0264 KEYIN1 gpio125
0x402a0268 KEYIN2 gpio126
0x402a026c SCL2 gpio127
0x402a0270 SDA2 gpio128
0x402a0274 CLK_AUX0 gpio129
0x402a0278 IIS1DI gpio130
0x402a027c IIS1DO gpio131
0x402a0280 IIS1CLK gpio132
0x402a0284 IIS1LRCK gpio133
0x402a0288 TRACECLK gpio134
0x402a028c TRACECTRL gpio135
0x402a0290 TRACEDAT0 gpio136
0x402a0294 TRACEDAT1 gpio137
0x402a0298 TRACEDAT2 gpio138
0x402a029c TRACEDAT3 gpio139
0x402a02a0 TRACEDAT4 gpio140
0x402a02a4 TRACEDAT5 gpio141
0x402a02a8 TRACEDAT6 gpio142
0x402a02ac TRACEDAT7 gpio143
0x402a02b0 EXTINT0 gpio144
0x402a02b4 EXTINT1 gpio145
0x402a02b8 SCL3 gpio146
0x402a02bc SDA3 gpio147
0x402a02c0 U1TXD gpio70
0x402a02c4 U1RXD gpio71
0x402a02c8 U2TXD gpio72
0x402a02cc U2RXD gpio73
0x402a02d0 U3TXD gpio74
0x402a02d4 U3RXD gpio75
0x402a02d8 U3CTS gpio76
0x402a02dc U3RTS gpio77
0x402a02e0 U4TXD gpio78
0x402a02e4 U4RXD gpio79
EOF
}

function get_pin_name() {
	pin_add=$1

	pin_name=$(show_pininfo | grep $1 | awk '{print $2}')
	if [ -z $pin_name ]; then
		pin_name="unknow"
	fi

	echo -n $pin_name
}

function print_pin_bit() {
	reg_val=$1
	reg_bit=$2
	info=$3

	case `bin_hex $reg_val $reg_bit 1` in
		0x00) echo -n "" ;;
		0x01) echo -n "$info " ;;
	esac
}

function print_pin_info() {
	reg_val=$1
	reg_bit=$2
	info1=$3
	info2=$4
	info3=$5
	info4=$6

	case `bin_hex $reg_val $reg_bit 3` in
		0x00) echo -n "$info1 " ;;
		0x01) echo -n "$info2 " ;;
		0x02) echo -n "$info3 " ;;
		0x03) echo -n "$info4 " ;;
	esac
}

function print_pin_drv() {
	reg_val=$1
	reg_bit=$2

	drv=$(echo -n $(printf "%d" $(($reg_val >> $reg_bit & 0xf))))
	echo -n "DS($drv) "
}

function print_sel_info() {
	reg_val=$1
	reg_bit=$2
	reg_mask=$3
	src=$4
	arr=($5)

	echo -n "$src=>"
	index=$(printf "%d" $(($reg_val >> $reg_bit & $reg_mask)))
	echo -n "${arr[$index]} "
}

function print_normal_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_pin_info $pin_val 4 "AF(0)" "AF(1)" "AF(2)" "AF(3)"					### function
	print_pin_drv $pin_val 19						### driver strength
	print_pin_bit $pin_val 12 "wpus"				### pull up
	print_pin_info $pin_val 6 "func_nul" "func_wpd" "func_wpu" "func_err"		### weakly pull up or down
	print_pin_info $pin_val 2 "slp_nul" "slp_wpd" "slp_wpu" "slp_err"			### sleep weakly pull up or down
	print_pin_info $pin_val 0 "slp_z" "slp_oe" "slp_ie" "slp_derr"				### sleep input or output
	print_pin_bit $pin_val 13 "slp_AP"				### sleep with
	print_pin_bit $pin_val 14 "slp_CP0"
	print_pin_bit $pin_val 15 "slp_CP1"
	print_pin_bit $pin_val 16 "slp_VCP0"
	print_pin_bit $pin_val 17 "slp_VCP1"
	echo ""
}

function print_reg0_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 28 1 "WIFI_COEXIST" "MEMS_MIC_CLK0 TRACEDAT07"
	print_sel_info $pin_val 27 1 "ORP_URXD" "U1RXD U2RXD"
	print_pin_bit $pin_val 15 "wpd_nf1pd"
	print_pin_bit $pin_val 14 "wpd_nf0pd"
	print_pin_bit $pin_val 13 "wpd_adpd"
	print_pin_bit $pin_val 12 "wpd_io_2_1pd"
	print_pin_bit $pin_val 11 "wpd_iopd"
	print_pin_bit $pin_val 10 "wpd_sim2pd"
	print_pin_bit $pin_val 9 "wpd_sim1pd"
	print_pin_bit $pin_val 8 "wpd_sim0pd"
	print_pin_bit $pin_val 7 "wpd_sdpd"
	print_pin_bit $pin_val 6 "wpd_campd"
	echo ""
}

function print_reg1_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 3 1 "U4RXD" "U4RXD SDA3"
	echo ""
}

function print_reg2_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 25 3 "SIM2" "AP_SIM0 CP0_SIM2 CP1_SIM2"
	print_sel_info $pin_val 23 3 "SIM1" "CP1_SIM1 CP0_SIM1 AP_SIM0"
	print_sel_info $pin_val 21 3 "SIM0" "CP0_SIM0 CP1_SIM0 AP_SIM0"
	print_sel_info $pin_val 18 7 "UART4" "AP_UART4 CP0_UART0 CP0_UART1 CP0_UART2 CP0_UART3"
	print_sel_info $pin_val 15 7 "UART3" "AP_UART3 CP0_UART0 CP0_UART1 CP0_UART2 CP0_UART3 ARM7_UART0"
	print_sel_info $pin_val 11 15 "UART2" "AP_UART2 AP_UART1 AP_UART0 AP_UART3 AP_UART4 CP0_UART0 CP0_UART1 CP0_UART2 CP0_UART3 CP1_UART0 CP1_UART1 ARM7_UART0"
	print_sel_info $pin_val 7 15 "UART1" "AP_UART1 AP_UART0 AP_UART2 AP_UART3 AP_UART4 CP0_UART0 CP0_UART1 CP0_UART2 CP0_UART3 CP1_UART0 CP1_UART1 ARM7_UART0"
	print_sel_info $pin_val 4 7 "UART0" "AP_UART0 CP0_UART0 CP1_UART0 ARM7_UART0"
	print_pin_bit $pin_val 3 "uart24_loop_sel"
	print_pin_bit $pin_val 2 "uart23_loop_sel"
	print_pin_bit $pin_val 1 "uart14_loop_sel"
	print_pin_bit $pin_val 0 "uart13_loop_sel"
	echo ""
}

function print_reg3_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 31 1 "Watch_dog_reset" "CA7 AP"
	print_sel_info $pin_val 15 7 "IIS3" "AP_IIS3 CP0_IIS3 CP1_IIS3 CP2_IIS VBC_IIS0 VBC_IIS1"
	print_sel_info $pin_val 12 7 "IIS2" "AP_IIS2 CP0_IIS2 CP1_IIS2 VBC_IIS0 VBC_IIS1"
	print_sel_info $pin_val 9 7 "IIS1" "AP_IIS1 CP0_IIS1 CP1_IIS1 VBC_IIS0 VBC_IIS1"
	print_sel_info $pin_val 6 7 "IIS0" "AP_IIS0 CP0_IIS0 CP1_IIS0 VBC_IIS0 VBC_IIS1"
	print_pin_bit $pin_val 5 "Iis23_loop_sel"
	print_pin_bit $pin_val 4 "Iis13_loop_sel"
	print_pin_bit $pin_val 3 "uart24_loop_sel"
	print_pin_bit $pin_val 2 "iis03_loop_sel"
	print_pin_bit $pin_val 1 "iis02_loop_sel"
	print_pin_bit $pin_val 0 "iis01_loop_sel"
	echo ""
}

function print_reg4_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 27 1 "MCSI1_DN1" "ccir_vs GPIO179"
	print_sel_info $pin_val 26 1 "MCSI1_DP1" "ccir_hs GPIO178"
	print_sel_info $pin_val 25 1 "MCSI1_DN0" "ccir_d[6] GPIO177"
	print_sel_info $pin_val 24 1 "MCSI1_DP0" "ccir_d[6] GPIO176"
	print_sel_info $pin_val 23 1 "MCSI1_CLKN" "ccir_d[5] GPIO175"
	print_sel_info $pin_val 22 1 "MCSI1_CLKP" "ccir_d[4] GPIO174"
	print_sel_info $pin_val 21 1 "MCSI0_DN3" "ccir_d[3] GPIO173"
	print_sel_info $pin_val 20 1 "MCSI0_DP3" "ccir_d[2] GPIO172"

	print_sel_info $pin_val 6 1 "VSD1" "3.0v 1.8v"
	print_sel_info $pin_val 5 1 "VSD" "3.0v 1.8v"
	print_sel_info $pin_val 4 1 "VSIM2" "3.0v 1.8v"
	print_sel_info $pin_val 3 1 "VSIM1" "3.0v 1.8v"
	print_sel_info $pin_val 2 1 "VSIM0" "3.0v 1.8v"
	print_sel_info $pin_val 1 1 "VIO_2_1" "3.0v 1.8v"
	print_sel_info $pin_val 0 1 "VIO" "3.0v 1.8v"
	echo ""
}

function print_reg5_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 0 1 "Debug_mode" "disable enable"
	echo ""
}

function check_by_addr() {
	pin_add=$1

	adb shell lookat -l1 $pin_add | while read LINE
	do
		if [[ "$LINE" =~ "0x" ]]; then
			pin_add=$(echo $LINE | awk '{print $1}' | sed 's/\r$//');
			pin_val=$(echo $LINE | awk '{print $3}' | sed 's/\r$//');
			if [[ "$pin_add" == "0x402a0000" ]]; then
				print_reg0_pin $pin_add $pin_val
			elif [[ "$pin_add" == "0x402a0004" ]]; then
				print_reg1_pin $pin_add $pin_val
			elif [[ "$pin_add" == "0x402a0008" ]]; then
				print_reg2_pin $pin_add $pin_val
			elif [[ "$pin_add" == "0x402a000c" ]]; then
				print_reg3_pin $pin_add $pin_val
			elif [[ "$pin_add" == "0x402a0010" ]]; then
				print_reg4_pin $pin_add $pin_val
			elif [[ "$pin_add" == "0x402a0014" ]]; then
				print_reg5_pin $pin_add $pin_val
			elif [[ "$pin_add" < "0x402a0020" ]]; then
				echo "$(get_pin_name $pin_add) : $pin_add($pin_val)"
			else
				print_normal_pin $pin_add $pin_val
			fi
		fi
	done
}

function check_by_value() {
	pin_val=$1

	print_normal_pin "unknow" $pin_val
}

filename=$(basename $0)
function help() {
	echo "$filename <-r reg>|<-v value>|-l|-h"
	echo "  -r: pin reg"
	echo "  -v: pin value"
	echo "  -l: list pin"
	echo "  -h: help"
	exit
}

case $1 in
	-r) check_by_addr $2 ;;
	-v) check_by_value $2 ;;
	-l) show_pininfo ;;
	-h) help ;;
	*)	help ;;
esac


