FUNC_ENABLE=0

READ_PIN=0x1
READ_MODULE_EB=0x2
READ_SLEEP_STATUS=0x4
READ_DDR_FREQ=0x8
READ_XTL_INFO=0x10
READ_PLL_SEL=0X20

if [ -e /system/bin/sh ]; then
	LOOKAT="lookat"
	PRINTF="busybox printf"
	TR="busybox tr"
	AWK="busybox awk"
	SED="busybox sed"
	BASENAME="busybox basename"
	EXPR="busybox expr"
else
	LOOKAT="adb shell lookat"
	PRINTF="printf"
	TR="tr"
	AWK="awk"
	SED="sed"
	BASENAME="basename"
	EXPR="expr"
fi

filename=$($BASENAME $0)

function help() {
	echo "$filename [-h|-a|-p|-m|-s|-d|-x|-l]"
	echo "  -h: help"
	echo "  -a: all"
	echo "  -p: print pinmap"
	echo "  -m: print module eb"
	echo "  -s: print sleep status"
	echo "  -d: print ddr info"
	echo "  -x: print xtl cfg"
	echo "  -l: print pll cfg"
}

if (($#>0)); then
	FUNC_ENABLE=0

	while [ -n "$1" ]; do
		case $1 in
			-h) help ;;
			-a) FUNC_ENABLE=0xffffffff ;;
			-p) FUNC_ENABLE=$(($FUNC_ENABLE|$READ_PIN)) ;;
			-m) FUNC_ENABLE=$(($FUNC_ENABLE|$READ_MODULE_EB)) ;;
			-s) FUNC_ENABLE=$(($FUNC_ENABLE|$READ_SLEEP_STATUS)) ;;
			-d) FUNC_ENABLE=$(($FUNC_ENABLE|$READ_DDR_FREQ)) ;;
			-x) FUNC_ENABLE=$(($FUNC_ENABLE|$READ_XTL_INFO)) ;;
			-l) FUNC_ENABLE=$(($FUNC_ENABLE|$READ_PLL_SEL)) ;;
			*) ;;
		esac
		shift 1
	done
else
	help
	exit
fi

function hex() {
	$PRINTF "0x%08x" $1
}

function hex1() {
	$PRINTF "0x%02x" $1
}

function hex3() {
	$PRINTF "0x%02x" $1
}

function hex4() {
	$PRINTF "0x%02x" $1
}

function hex7() {
	$PRINTF "0x%02x" $1
}

function read_reg() {
	$LOOKAT $(hex $(($1 + $2))) | $SED 's/\r$//'
}

function bin_hex() {
	value=$1
	vshift=$2
	vmask=$3
	echo -n $(`$EXPR hex$vmask` $(($value >> $vshift & $vmask)))
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

if (($READ_PIN & $FUNC_ENABLE)); then
echo "===============================  pinmap config  ================================="
function get_pin_name() {
	pin_add=$1

	case $pin_add in
		0x402a0000) echo -n "REG_PIN_CTRL0" ;;
		0x402a0004) echo -n "REG_PIN_CTRL1" ;;
		0x402a0008) echo -n "REG_PIN_CTRL2" ;;
		0x402a000c) echo -n "REG_PIN_CTRL3" ;;
		0x402a0010) echo -n "REG_PIN_CTRL4" ;;
		0x402a0014) echo -n "REG_PIN_CTRL5" ;;
		0x402a0018) echo -n "REG_PIN_CTRL6" ;;
		0x402a001c) echo -n "REG_PIN_CTRL7" ;;
		0x402a0020) echo -n "REG_PIN_RFSDA0" ;;
		0x402a0024) echo -n "REG_PIN_RFSCK0" ;;
		0x402a0028) echo -n "REG_PIN_RFSEN0" ;;
		0x402a002c) echo -n "REG_PIN_RFCTL0" ;;
		0x402a0030) echo -n "REG_PIN_RFCTL1" ;;
		0x402a0034) echo -n "REG_PIN_RFCTL2" ;;
		0x402a0038) echo -n "REG_PIN_RFCTL3" ;;
		0x402a003c) echo -n "REG_PIN_RFCTL4" ;;
		0x402a0040) echo -n "REG_PIN_RFCTL5" ;;
		0x402a0044) echo -n "REG_PIN_RFCTL6" ;;
		0x402a0048) echo -n "REG_PIN_RFCTL7" ;;
		0x402a004c) echo -n "REG_PIN_RFCTL8" ;;
		0x402a0050) echo -n "REG_PIN_RFCTL9" ;;
		0x402a0054) echo -n "REG_PIN_RFCTL10" ;; 
		0x402a0058) echo -n "REG_PIN_RFCTL11" ;;
		0x402a005c) echo -n "REG_PIN_RFCTL12" ;;
		0x402a0060) echo -n "REG_PIN_RFCTL13" ;;
		0x402a0064) echo -n "REG_PIN_RFCTL14" ;;
		0x402a0068) echo -n "REG_PIN_RFCTL15" ;;
		0x402a006c) echo -n "REG_PIN_PTEST" ;;
		0x402a0070) echo -n "REG_PIN_ANA_INT" ;;
		0x402a0074) echo -n "REG_PIN_EXT_RST_B" ;;
		0x402a0078) echo -n "REG_PIN_CHIP_SLEEP" ;;
		0x402a007c) echo -n "REG_PIN_XTL_BUF_EN0" ;;
		0x402a0080) echo -n "REG_PIN_XTL_BUF_EN1" ;;
		0x402a0084) echo -n "REG_PIN_CLK_32K" ;;
		0x402a0088) echo -n "REG_PIN_AUD_SCLK" ;;   
		0x402a008c) echo -n "REG_PIN_AUD_ADD0" ;;   
		0x402a0090) echo -n "REG_PIN_AUD_ADSYNC" ;; 
		0x402a0094) echo -n "REG_PIN_AUD_DAD1" ;;   
		0x402a0098) echo -n "REG_PIN_AUD_DAD0" ;;   
		0x402a009c) echo -n "REG_PIN_AUD_DASYNC" ;; 
		0x402a00a0) echo -n "REG_PIN_ADI_D" ;; 
		0x402a00a4) echo -n "REG_PIN_ADI_SYNC" ;;   
		0x402a00a8) echo -n "REG_PIN_ADI_SCLK" ;;   
		0x402a00ac) echo -n "REG_PIN_LCD_RSTN" ;;   
		0x402a00b0) echo -n "REG_PIN_LCD_FMARK" ;;  
		0x402a00b4) echo -n "REG_PIN_SPI1_CSN" ;;   
		0x402a00b8) echo -n "REG_PIN_SPI1_DO" ;;    
		0x402a00bc) echo -n "REG_PIN_SPI1_DI" ;;    
		0x402a00c0) echo -n "REG_PIN_SPI1_CLK" ;;   
		0x402a00c4) echo -n "REG_PIN_NFWPN" ;; 
		0x402a00c8) echo -n "REG_PIN_NFRBN" ;; 
		0x402a00cc) echo -n "REG_PIN_NFCLE" ;; 
		0x402a00d0) echo -n "REG_PIN_NFALE" ;; 
		0x402a00d4) echo -n "REG_PIN_NFREN" ;; 
		0x402a00d8) echo -n "REG_PIN_NFD4" ;;  
		0x402a00dc) echo -n "REG_PIN_NFD5" ;;  
		0x402a00e0) echo -n "REG_PIN_NFD6" ;;  
		0x402a00e4) echo -n "REG_PIN_NFD7" ;;  
		0x402a00e8) echo -n "REG_PIN_NFD10" ;; 
		0x402a00ec) echo -n "REG_PIN_NFD11" ;; 
		0x402a00f0) echo -n "REG_PIN_NFD14" ;; 
		0x402a00f4) echo -n "REG_PIN_NFCEN0" ;;
		0x402a00f8) echo -n "REG_PIN_NFCEN1" ;;
		0x402a00fc) echo -n "REG_PIN_NFWEN" ;; 
		0x402a0100) echo -n "REG_PIN_NFD0" ;;  
		0x402a0104) echo -n "REG_PIN_NFD1" ;;  
		0x402a0108) echo -n "REG_PIN_NFD2" ;;  
		0x402a010c) echo -n "REG_PIN_NFD3" ;;  
		0x402a0110) echo -n "REG_PIN_NFD8" ;;  
		0x402a0114) echo -n "REG_PIN_NFD9" ;;  
		0x402a0118) echo -n "REG_PIN_NFD12" ;; 
		0x402a011c) echo -n "REG_PIN_NFD13" ;; 
		0x402a0120) echo -n "REG_PIN_NFD15" ;; 
		0x402a0124) echo -n "REG_PIN_CCIRMCLK" ;;   
		0x402a0128) echo -n "REG_PIN_CCIRRST" ;;    
		0x402a012c) echo -n "REG_PIN_CCIRPD1" ;;    
		0x402a0130) echo -n "REG_PIN_CCIRPD0" ;;    
		0x402a0134) echo -n "REG_PIN_SCL0" ;;  
		0x402a0138) echo -n "REG_PIN_SDA0" ;;  
		0x402a013c) echo -n "REG_PIN_KEYOUT0" ;;    
		0x402a0140) echo -n "REG_PIN_KEYOUT1" ;;    
		0x402a0144) echo -n "REG_PIN_KEYOUT2" ;;    
		0x402a0148) echo -n "REG_PIN_KEYIN0" ;;
		0x402a014c) echo -n "REG_PIN_KEYIN1" ;;
		0x402a0150) echo -n "REG_PIN_KEYIN2" ;;
		0x402a0154) echo -n "REG_PIN_CLK_AUX0" ;;   
		0x402a0158) echo -n "REG_PIN_CLK_AUX1" ;;   
		0x402a015c) echo -n "REG_PIN_IIS0DI" ;;
		0x402a0160) echo -n "REG_PIN_IIS0DO" ;;
		0x402a0164) echo -n "REG_PIN_IIS0CLK" ;;    
		0x402a0168) echo -n "REG_PIN_IIS0LRCK" ;;   
		0x402a016c) echo -n "REG_PIN_MTDO" ;;  
		0x402a0170) echo -n "REG_PIN_MTDI" ;;  
		0x402a0174) echo -n "REG_PIN_MTCK" ;;  
		0x402a0178) echo -n "REG_PIN_MTMS" ;;  
		0x402a017c) echo -n "REG_PIN_MTRST_N" ;;    
		0x402a0180) echo -n "REG_PIN_TRACECLK" ;;   
		0x402a0184) echo -n "REG_PIN_TRACECTRL" ;;  
		0x402a0188) echo -n "REG_PIN_TRACEDAT0" ;;  
		0x402a018c) echo -n "REG_PIN_TRACEDAT1" ;;  
		0x402a0190) echo -n "REG_PIN_TRACEDAT2" ;;  
		0x402a0194) echo -n "REG_PIN_TRACEDAT3" ;;  
		0x402a0198) echo -n "REG_PIN_TRACEDAT4" ;;  
		0x402a019c) echo -n "REG_PIN_TRACEDAT5" ;;  
		0x402a01a0) echo -n "REG_PIN_TRACEDAT6" ;;  
		0x402a01a4) echo -n "REG_PIN_TRACEDAT7" ;;  
		0x402a01a8) echo -n "REG_PIN_U0TXD" ;; 
		0x402a01ac) echo -n "REG_PIN_U0RXD" ;; 
		0x402a01b0) echo -n "REG_PIN_U0CTS" ;; 
		0x402a01b4) echo -n "REG_PIN_U0RTS" ;; 
		0x402a01b8) echo -n "REG_PIN_U1TXD" ;; 
		0x402a01bc) echo -n "REG_PIN_U1RXD" ;; 
		0x402a01c0) echo -n "REG_PIN_U2TXD" ;; 
		0x402a01c4) echo -n "REG_PIN_U2RXD" ;; 
		0x402a01c8) echo -n "REG_PIN_U2CTS" ;; 
		0x402a01cc) echo -n "REG_PIN_U2RTS" ;; 
		0x402a01d0) echo -n "REG_PIN_SCL2" ;;  
		0x402a01d4) echo -n "REG_PIN_SDA2" ;;  
		0x402a01d8) echo -n "REG_PIN_EXTINT0" ;;    
		0x402a01dc) echo -n "REG_PIN_EXTINT1" ;;    
		0x402a01e0) echo -n "REG_PIN_SCL1" ;;  
		0x402a01e4) echo -n "REG_PIN_SDA1" ;;  
		0x402a01e8) echo -n "REG_PIN_SIMCLK0" ;;    
		0x402a01ec) echo -n "REG_PIN_SIMDA0" ;;
		0x402a01f0) echo -n "REG_PIN_SIMRST0" ;;    
		0x402a01f4) echo -n "REG_PIN_SIMCLK1" ;;    
		0x402a01f8) echo -n "REG_PIN_SIMDA1" ;;
		0x402a01fc) echo -n "REG_PIN_SIMRST1" ;;    
		0x402a0200) echo -n "REG_PIN_SIMCLK2" ;;    
		0x402a0204) echo -n "REG_PIN_SIMDA2" ;;
		0x402a0208) echo -n "REG_PIN_SIMRST2" ;;    
		0x402a020c) echo -n "REG_PIN_SD1_CLK" ;;    
		0x402a0210) echo -n "REG_PIN_SD1_CMD" ;;    
		0x402a0214) echo -n "REG_PIN_SD1_D0" ;;
		0x402a0218) echo -n "REG_PIN_SD1_D1" ;;
		0x402a021c) echo -n "REG_PIN_SD1_D2" ;;
		0x402a0220) echo -n "REG_PIN_SD1_D3" ;;
		0x402a0224) echo -n "REG_PIN_SD0_D3" ;;
		0x402a0228) echo -n "REG_PIN_SD0_D2" ;;
		0x402a022c) echo -n "REG_PIN_SD0_CMD" ;;    
		0x402a0230) echo -n "REG_PIN_SD0_D0" ;;
		0x402a0234) echo -n "REG_PIN_SD0_D1" ;;
		0x402a0238) echo -n "REG_PIN_SD0_CLK0" ;;   
		0x402a023c) echo -n "REG_PIN_RF_ADC_ON" ;;  
		0x402a0240) echo -n "REG_PIN_RF_DAC_ON" ;;  
		0x402a0244) echo -n "REG_PIN_EMD4" ;;  
		0x402a0248) echo -n "REG_PIN_EMD7" ;;  
		0x402a024c) echo -n "REG_PIN_EMD5" ;;  
		0x402a0250) echo -n "REG_PIN_EMDQS0" ;;
		0x402a0254) echo -n "REG_PIN_EMDQS_N0" ;;   
		0x402a0258) echo -n "REG_PIN_EMD2" ;;  
		0x402a025c) echo -n "REG_PIN_EMD1" ;;  
		0x402a0260) echo -n "REG_PIN_EMD0" ;;  
		0x402a0264) echo -n "REG_PIN_EMD6" ;;  
		0x402a0268) echo -n "REG_PIN_EMD3" ;;  
		0x402a026c) echo -n "REG_PIN_EMDQM0" ;;
		0x402a0270) echo -n "REG_PIN_EMD13" ;; 
		0x402a0274) echo -n "REG_PIN_EMD12" ;; 
		0x402a0278) echo -n "REG_PIN_EMD15" ;; 
		0x402a027c) echo -n "REG_PIN_EMDQS1" ;;
		0x402a0280) echo -n "REG_PIN_EMDQS_N1" ;;   
		0x402a0284) echo -n "REG_PIN_EMD9" ;;  
		0x402a0288) echo -n "REG_PIN_EMD11" ;; 
		0x402a028c) echo -n "REG_PIN_EMD10" ;; 
		0x402a0290) echo -n "REG_PIN_EMD8" ;;  
		0x402a0294) echo -n "REG_PIN_EMD14" ;; 
		0x402a0298) echo -n "REG_PIN_EMDQM1" ;;
		0x402a029c) echo -n "REG_PIN_EMZQ" ;;  
		0x402a02a0) echo -n "REG_PIN_EMA3" ;;
		0x402a02a4) echo -n "REG_PIN_EMA2" ;;
		0x402a02a8) echo -n "REG_PIN_EMA1" ;;
		0x402a02ac) echo -n "REG_PIN_EMA6" ;;
		0x402a02b0) echo -n "REG_PIN_CLKDPMEM" ;;   
		0x402a02b4) echo -n "REG_PIN_CLKDMMEM" ;;   
		0x402a02b8) echo -n "REG_PIN_EMCKE1" ;;
		0x402a02bc) echo -n "REG_PIN_EMCKE0" ;;
		0x402a02c0) echo -n "REG_PIN_EMA8" ;;  
		0x402a02c4) echo -n "REG_PIN_EMA7" ;;  
		0x402a02c8) echo -n "REG_PIN_EMA5" ;;
		0x402a02cc) echo -n "REG_PIN_EMA4" ;;
		0x402a02d0) echo -n "REG_PIN_EMA9" ;;
		0x402a02d4) echo -n "REG_PIN_EMA0" ;;
		0x402a02d8) echo -n "REG_PIN_EMCS_N1" ;;    
		0x402a02dc) echo -n "REG_PIN_EMCS_N0" ;;    
		0x402a02e0) echo -n "REG_PIN_EMD22" ;; 
		0x402a02e4) echo -n "REG_PIN_EMD21" ;; 
		0x402a02e8) echo -n "REG_PIN_EMD23" ;; 
		0x402a02ec) echo -n "REG_PIN_EMDQS2" ;;
		0x402a02f0) echo -n "REG_PIN_EMDQS_N2" ;;   
		0x402a02f4) echo -n "REG_PIN_EMD20" ;; 
		0x402a02f8) echo -n "REG_PIN_EMD18" ;; 
		0x402a02fc) echo -n "REG_PIN_EMD16" ;; 
		0x402a0300) echo -n "REG_PIN_EMD19" ;; 
		0x402a0304) echo -n "REG_PIN_EMD17" ;; 
		0x402a0308) echo -n "REG_PIN_EMDQM2" ;;
		0x402a030c) echo -n "REG_PIN_EMD28" ;;
		0x402a0310) echo -n "REG_PIN_EMD29" ;;
		0x402a0314) echo -n "REG_PIN_EMD31" ;;
		0x402a0318) echo -n "REG_PIN_EMDQS3" ;;
		0x402a031c) echo -n "REG_PIN_EMDQS_N3" ;;
		0x402a0320) echo -n "REG_PIN_EMD30" ;;
		0x402a0324) echo -n "REG_PIN_EMD26" ;;
		0x402a0328) echo -n "REG_PIN_EMD27" ;;
		0x402a032c) echo -n "REG_PIN_EMD25" ;;
		0x402a0330) echo -n "REG_PIN_EMD24" ;;
		0x402a0334) echo -n "REG_PIN_EMDQM3" ;;
		0x402a0338) echo -n "REG_PIN_CP2_RFCTL0" ;;
		0x402a033c) echo -n "REG_PIN_CP2_RFCTL1" ;;
		0x402a0340) echo -n "REG_PIN_CP2_RFCTL2" ;;
	esac
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

	drv=$(echo -n $($PRINTF "%d" $(($reg_val >> $reg_bit & 0xf))))
	echo -n "DS($drv) "
}

function print_sel_info() {
	reg_val=$1
	reg_bit=$2
	reg_mask=$3
	src=$4
	arr=($5)

	echo -n "$src=>"
	index=$($PRINTF "%d" $(($reg_val >> $reg_bit & $reg_mask)))
	echo -n "${arr[$index]} "
}

function print_normal_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_pin_info $pin_val 4 "AF(0)" "AF(1)" "AF(2)" "AF(3)"					### function
	print_pin_drv $pin_val 18						### driver strength
	print_pin_bit $pin_val 12 "wpus"				### pull up
	print_pin_info $pin_val 6 "func_nul" "func_wpd" "func_wpu" "func_err"		### weakly pull up or down
	print_pin_info $pin_val 2 "slp_nul" "slp_wpd" "slp_wpu" "slp_err"			### sleep weakly pull up or down
	print_pin_info $pin_val 0 "slp_z" "slp_oe" "slp_ie" "slp_derr"				### sleep input or output
	print_pin_bit $pin_val 13 "slp_AP"				### sleep with
	print_pin_bit $pin_val 14 "slp_CP0"
	print_pin_bit $pin_val 15 "slp_CP1"
	print_pin_bit $pin_val 16 "slp_CP2"
	echo ""
}

function print_reg_value_only() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	echo ""
}

function print_reg2_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 31 1 "usb_uart1_sel" "UART USBDP/DM"
	print_sel_info $pin_val 29 3 "usb_uart_oe" "receiver transmitter"
	print_sel_info $pin_val 22 1 "sim2_sys_sel" "cp0_sim2 ap_sim0"
	print_sel_info $pin_val 21 1 "sim1_sys_sel" "cp0_sim1 ap_sim0"
	print_sel_info $pin_val 20 1 "sim0_sys_sel" "cp0_sim0 ap_sim0"
	print_sel_info $pin_val 10 7 "UART2" "AP_UART2 CP0_UART1 CP2_UART0 CP2_UART1"
	print_sel_info $pin_val 7 7 "UART1" "AP_UART1 CP0_UART1 CP2_UART0 CP2_UART1"
	print_sel_info $pin_val 4 7 "UART0" "AP_UART0 CP0_UART0 CP2_UART0 CP2_UART1"
	echo ""
}

function print_reg3_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 31 1 "wdrst_out_sel" "CA7_watchdog AP_watchdog"
	print_sel_info $pin_val 18 1 "CP_ARM_GPIO" "CP0 CP2"
	print_sel_info $pin_val 8 3 "iis1_sys_sel" "AP_IIS1 CP0_IIS1 CP2_IIS0 VBC_IIS0"
	print_sel_info $pin_val 6 3 "iis0_sys_sel" "AP_IIS0 CP0_IIS0 CP2_IIS0 VBC_IIS0"
	print_pin_bit $pin_val 0 "iis01_loop_sel"
	echo ""
}

function print_reg4_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 28 1 "VIO28_pp1_boost?=" "No Yes"
	print_sel_info $pin_val 27 1 "VIOSIM2_pp1_boost?=" "No Yes"
	print_sel_info $pin_val 26 1 "VIOSIM1_pp1_boost?=" "No Yes"
	print_sel_info $pin_val 25 1 "VIOSIM0_pp1_boost?=" "No Yes"
	print_sel_info $pin_val 24 1 "VIOSD0_pp1_boost?=" "No Yes"
	
	print_sel_info $pin_val 20 1 "VIO28_ms" "1.8v 3.0v"
	print_sel_info $pin_val 19 1 "VIOSIM2_ms" "1.8v 3.0v"
	print_sel_info $pin_val 18 1 "VIOSIM1_ms" "1.8v 3.0v"
	print_sel_info $pin_val 17 1 "VIOSIM0_ms" "1.8v 3.0v"
	print_sel_info $pin_val 16 1 "VIOSD0_ms" "1.8v 3.0v"

	print_sel_info $pin_val 7 1 "dbg_mode7_enable?=" "No Yes"
	print_sel_info $pin_val 6 1 "dbg_mode6_enable?=" "No Yes"
	print_sel_info $pin_val 5 1 "dbg_mode5_enable?=" "No Yes"
	print_sel_info $pin_val 4 1 "dbg_mode4_enable?=" "No Yes"
	print_sel_info $pin_val 3 1 "dbg_mode3_enable?=" "No Yes"
	print_sel_info $pin_val 2 1 "dbg_mode2_enable?=" "No Yes"
	print_sel_info $pin_val 1 1 "dbg_mode1_enable?=" "No Yes"
	print_sel_info $pin_val 0 1 "dbg_mode0_enable?=" "No Yes"
	echo ""
}

function print_reg5_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 0 1 "DDR_EMD=" "DMC IOMUX"
	echo ""
}

function print_reg6_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 29 3 "DDR_EMODT=" "DMC IOMUX"
	print_sel_info $pin_val 28 1 "DDR_EMRSTN=" "DMC IOMUX"
	print_sel_info $pin_val 27 1 "DDR_EMRASN=" "DMC IOMUX"
	print_sel_info $pin_val 26 1 "DDR_EMCASN=" "DMC IOMUX"
	print_sel_info $pin_val 25 1 "DDR_EMWEN=" "DMC IOMUX"
	print_sel_info $pin_val 24 1 "DDR_EMCLKDM=" "DMC IOMUX"
	print_sel_info $pin_val 23 1 "DDR_EMCLKDP=" "DMC IOMUX"
	
	print_sel_info $pin_val 21 3 "DDR_EMCKE=" "DMC IOMUX"
	print_sel_info $pin_val 19 3 "DDR_EMCSN=" "DMC IOMUX"
	print_sel_info $pin_val 16 7 "DDR_EMBA=" "DMC IOMUX"
	print_sel_info $pin_val 0 1 "DDR_EMA=" "DMC IOMUX"
	echo ""
}

function print_reg7_pin() {
	pin_add=$1
	pin_val=$2

	pin_name=$(get_pin_name $pin_add)

	echo -n "$pin_name : $pin_add($pin_val) :  "
	print_sel_info $pin_val 20 1 "VIO28_pwd?=" "No Yes"
	print_sel_info $pin_val 19 1 "VIOSIM2_pwd?=" "No Yes"
	print_sel_info $pin_val 18 1 "VIOSIM1_pwd?=" "No Yes"
	print_sel_info $pin_val 17 1 "VIOSIM0_pwd?=" "No Yes"
	print_sel_info $pin_val 16 1 "VIOSD0_pwd?=" "No Yes"
	print_sel_info $pin_val 8 15 "DDR_EMDQSN=" "DMC IOMUX"
	print_sel_info $pin_val 4 15 "DDR_EMDQS=" "DMC IOMUX"
	print_sel_info $pin_val 0 15 "DDR_EMDQM=" "DMC IOMUX"
	echo ""
}

$LOOKAT -l209 0x402a0000 | while read LINE
do
#	if [[ "$LINE" =~ "0x" ]]; then
	is_hex=$(echo $LINE | $AWK '/0x/{print 1}')
	if [[ $is_hex ]]; then
		pin_add=$(echo $LINE | $AWK '{print $1}' | $SED 's/\r$//');
		pin_val=$(echo $LINE | $AWK '{print $3}' | $SED 's/\r$//');
		if [[ "$pin_add" == "0x402a0000" ]]; then
			print_reg_value_only $pin_add $pin_val
		elif [[ "$pin_add" == "0x402a0004" ]]; then
			print_reg_value_only $pin_add $pin_val
		elif [[ "$pin_add" == "0x402a0008" ]]; then
			print_reg2_pin $pin_add $pin_val
		elif [[ "$pin_add" == "0x402a000c" ]]; then
			print_reg3_pin $pin_add $pin_val
		elif [[ "$pin_add" == "0x402a0010" ]]; then
			print_reg4_pin $pin_add $pin_val
		elif [[ "$pin_add" == "0x402a0014" ]]; then
			print_reg5_pin $pin_add $pin_val
		elif [[ "$pin_add" == "0x402a0018" ]]; then
			print_reg6_pin $pin_add $pin_val
		elif [[ "$pin_add" == "0x402a001C" ]]; then
			print_reg7_pin $pin_add $pin_val
		else
			print_normal_pin $pin_add $pin_val
		fi
	fi
done
echo "=================================================================================="
echo " "
fi


if (($READ_MODULE_EB & $FUNC_ENABLE)); then
echo "===============================  module eb list ================================="
##### AHB_EB
val=$(read_reg 0x20d00000 0x00)
echo "=== AHB_EB(0x20e00000 : $val) ==="

print_bit $val 22 "LVDS_EB"
print_bit $val 21 "ZIPDEC_EB"
print_bit $val 20 "ZIPENC_EB"
print_bit $val 19 "NANDC_ECC_EB"
print_bit $val 18 "NANDC_2X_EB"
print_bit $val 17 "NANDC_EB"
print_bit $val 16 "BUSMON2_EB"
print_bit $val 15 "BUSMON1_EB"
print_bit $val 14 "BUSMON0_EB"
print_bit $val 13 "SPINLOCK_EB"
print_bit $val 12 "GPS_EB"
print_bit $val 11 "EMMC_EB"
print_bit $val 10 "SDIO2_EB"
print_bit $val 9 "SDIO1_EB"
print_bit $val 8 "SDIO0_EB"
print_bit $val 7 "DRM_EB"
print_bit $val 6 "NFC_EB"
print_bit $val 5 "DMA_EB"
print_bit $val 4 "USB_EB"
print_bit $val 3 "GSP_EB"
print_bit $val 2 "HSIC_EB"
print_bit $val 1 "DISPC_EB"
print_bit $val 0 "DSI_EB"
echo " "

##### APB_EB
val=$(read_reg 0x71300000 0x0)
echo "=== APB_EB(0x71300000 : $val) ==="

print_bit $val 22 "INTC3_EB"
print_bit $val 21 "INTC2_EB"
print_bit $val 20 "INTC1_EB"
print_bit $val 19 "INTC0_EB"
print_bit $val 18 "CKG_EB"
print_bit $val 17 "UART4_EB"
print_bit $val 16 "UART3_EB"
print_bit $val 15 "UART2_EB"
print_bit $val 14 "UART1_EB"
print_bit $val 13 "UART0_EB"
print_bit $val 12 "I2C4_EB"
print_bit $val 11 "I2C3_EB"
print_bit $val 10 "I2C2_EB"
print_bit $val 9 "I2C1_EB"
print_bit $val 8 "I2C0_EB"
print_bit $val 7 "SPI2_EB"
print_bit $val 6 "SPI1_EB"
print_bit $val 5 "SPI0_EB"
print_bit $val 4 "IIS3_EB"
print_bit $val 3 "IIS2_EB"
print_bit $val 2 "IIS1_EB"
print_bit $val 1 "IIS0_EB"
print_bit $val 0 "SIM0_EB"
echo " "

##### AON_APB_EB0
val=$(read_reg 0x402e0000 0x0)
echo "=== AON_APB_EB0(0x402e0000 : $val) ==="

print_bit $val 31 "I2C_EB"
print_bit $val 30 "CA7_DAP_EB"
print_bit $val 29 "CA7_TS1_EB"
print_bit $val 28 "CA7_TS0_EB"
print_bit $val 27 "GPU_EB"
print_bit $val 26 "CKG_EB"
print_bit $val 25 "MM_EB"
print_bit $val 24 "AP_WDG_EB"
print_bit $val 23 "MSPI_EB"
print_bit $val 22 "SPLK_EB"
print_bit $val 21 "IPI_EB"
print_bit $val 20 "PIN_EB"
print_bit $val 19 "VBC_EB"
print_bit $val 18 "AUD_EB"
print_bit $val 17 "AUDIF_EB"
print_bit $val 16 "ADI_EB"
print_bit $val 15 "INTC_EB"
print_bit $val 14 "EIC_EB"
print_bit $val 13 "EFUSE_EB"
print_bit $val 12 "AP_TMR0_EB"
print_bit $val 11 "AON_TMR_EB"
print_bit $val 10 "AP_SYST_EB"
print_bit $val 9 "AON_SYST_EB"
print_bit $val 8 "KPD_EB"
print_bit $val 7 "PWM3_EB"
print_bit $val 6 "PWM2_EB"
print_bit $val 5 "PWM1_EB"
print_bit $val 4 "PWM0_EB"
print_bit $val 3 "GPIO_EB"
print_bit $val 2 "TPC_EB"
print_bit $val 1 "FM_EB"
print_bit $val 0 "ADC_EB"
echo " "

##### AON_APB_EB1
val=$(read_reg 0x402e0000 0x4)
echo "=== AON_APB_EB1(0x402e0004 : $val) ==="

print_bit $val 20 "EMC_REF_CKG_EN"
print_bit $val 19 "DJTAG_EB"
print_bit $val 18 "RINGOSC_EB"
print_bit $val 17 "PUB_REG_EB"
print_bit $val 16 "DMC_EB"
print_bit $val 15 "RFTI_SBI_EB"
print_bit $val 14 "MDAR_EB"
print_bit $val 13 "GSP_EMC_EB"
print_bit $val 12 "ZIP_EMC_EB"
print_bit $val 11 "DISP_EMC_EB"
print_bit $val 10 "AP_TMR2_EB"
print_bit $val 9 "AP_TMR1_EB"
print_bit $val 8 "CA7_WDG_EB"
#print_bit $val 7 "AVS1_EB"
print_bit $val 6 "AVS0_EB"
print_bit $val 5 "PROBE_EB"
print_bit $val 4 "AUX2_EB"
print_bit $val 3 "AUX1_EB"
print_bit $val 2 "AUX0_EB"
print_bit $val 1 "THM_EB"
print_bit $val 0 "PMU_EB"
echo " "

echo "=================================================================================="
echo " "
fi

if (( $READ_SLEEP_STATUS & $FUNC_ENABLE )); then
function print_pwr_status_info() {
	reg_val=$1
	reg_bit=$2
	src=$3
	reg_mask=0xf
	arr=(WAKEUP POWER_ON_SEQ POWER_ON RST_ASSERT RST_GAP RESTORE ISO_OFF SHUTDOWN ACTIVE STANDBY ISO_ON SAVE_ST SAVE_GAP POWER_OFF BISR_RST BISR_PROC)

	echo -n "$src: "
	index=$($PRINTF "%d" $(($reg_val >> $reg_bit & $reg_mask)))
	echo "${arr[$index]} "
}

function print_sleep_status_info() {
	reg_val=$1
	reg_bit=$2
	src=$3
	reg_mask=0xf
	arr=(DEEP_SLEEP XTL_WAIT XTLBUF_WAIT DEEP_SLEEP_XTLON PLL_PWR_WAIT WAKEUP WAKEUP_LOCK NULL NULL NULL NULL NULL NULL NULL NULL NULL)

	echo -n "$src: "
	index=$($PRINTF "%d" $(($reg_val >> $reg_bit & $reg_mask)))
	echo "${arr[$index]} "
}

echo "===============================  sleep status  ================================="
##### CP_SLP_STATUS_DBG0
val=$(read_reg 0x402b0000 0xb4)
echo "=== CP_SLP_STATUS_DBG0(0x402b00b4 : $val) ==="

print_bit $val 15 "tmr_autopd_xtl_2g"
print_bit $val 14 "tmr_autopd_xtl_3g_w"
print_bit $val 13 "clk_ecc_en"
print_bit $val 12 "clk_qbc_en"
print_bit $val 11 "dsp_stop"
print_bit $val 10 "wsys_stop"
print_bit $val 9 "dsp_peri_stop"
print_bit $val 8 "mcu_peri_stop"
print_bit $val 7 "mcu_sys_stop"
print_bit $val 6 "mcu_deep_stop"
print_bit $val 5 "dsp_mahb_sleep_en"
print_bit $val 4 "ashb_dsptoarm_valid"
print_bit $val 3 "mcu_stop"
print_bit $val 2 "ahb_stop"
print_bit $val 1 "mtx_stop"
print_bit $val 0 "arm_stop"
echo " "

##### PWR_STATUS0_DBG
val=$(read_reg 0x402b0000 0xbc)
echo "=== PWR_STATUS0_DBG(0x402b00bc : $val) ==="

print_pwr_status_info $val 28 "PD_MM_TOP_STATE"
print_pwr_status_info $val 24 "PD_GPU_TOP_STATE"
print_pwr_status_info $val 16 "PD_CA7_C3_STATE"
print_pwr_status_info $val 12 "PD_CA7_C2_STATE"
print_pwr_status_info $val 8 "PD_CA7_C1_STATE"
print_pwr_status_info $val 4 "PD_CA7_C0_STATE"
print_pwr_status_info $val 0 "PD_CA7_TOP_STATE"
echo " "

##### PWR_STATUS1_DBG
val=$(read_reg 0x402b0000 0xc0)
echo "=== PWR_STATUS1_DBG(0x402b00c0 : $val) ==="

print_pwr_status_info $val 28 "PD_CP0_SYS_STATE"
print_pwr_status_info $val 20 "PD_CP0_GSM_0_STATE"
print_pwr_status_info $val 16 "PD_CP0_HU3GE_STATE"
print_pwr_status_info $val 12 "PD_CP0_ARM9_2_STATE"
print_pwr_status_info $val 8 "PD_CP0_ARM9_1_STATE"
print_pwr_status_info $val 4 "PD_CP0_ARM9_0_STATE"
print_pwr_status_info $val 0 "PD_AP_SYS_STATE"
echo " "

##### PWR_STATUS2_DBG
val=$(read_reg 0x402b0000 0xc4)
echo "=== PWR_STATUS2_DBG(0x402b00c4 : $val) ==="

print_pwr_status_info $val 24 "PD_CP2_WIFI_STATE"
print_pwr_status_info $val 20 "PD_CP2_ARM9_STATE"
print_pwr_status_info $val 16 "PD_CP1_SYS_STATE"
print_pwr_status_info $val 12 "PD_CP1_L1RAM_STATE"
print_pwr_status_info $val 8 "PD_CP1_TD_STATE"
print_pwr_status_info $val 4 "PD_CP1_GSM_STATE"
print_pwr_status_info $val 0 "PD_CP1_ARM9_STATE"
echo " "

##### PWR_STATUS3_DBG
val=$(read_reg 0x402b0000 0xc8)
echo "=== PWR_STATUS2_DBG(0x402b00c8 : $val) ==="

print_pwr_status_info $val 24 "PD_CP0_HARQ_STATE"
print_pwr_status_info $val 20 "PD_CP0_CEVA_STATE"
print_pwr_status_info $val 16 "PD_CP0_TD_STATE"
print_pwr_status_info $val 12 "PD_DDR_PHY_STATE"
print_pwr_status_info $val 8 "PD_DDR_PUBL_STATE"
print_pwr_status_info $val 4 "PD_PUB_SYS_STATE"
print_pwr_status_info $val 0 "PD_CP2_SYS_STATE"
echo " "

##### SLEEP_CTRL
val=$(read_reg 0x402b0000 0xcc)
echo "=== SLEEP_CTRL(0x402b00cc : $val) ==="

print_bit $val 12 "CP0_FORCE_S_LIGHT_SLEEP"
print_bit $val 11 "ACP2_SLEEP_XTL_ON"
print_bit $val 10 "CP1_SLEEP_XTL_ON"
print_bit $val 9 "CP0_SLEEP_XTL_ON"
print_bit $val 8 "AP_SLEEP_XTL_ON"

print_bit $val 3 "CP2_DEEP_SLEEP"
print_bit $val 2 "CP1_DEEP_SLEEP"
print_bit $val 1 "CP0_DEEP_SLEEP"
print_bit $val 0 "AP_DEEP_SLEEP"
echo " "

##### DDR_SLEEP_CTRL
val=$(read_reg 0x402b0000 0xd0)
echo "=== SLEEP_CTRL(0x402b00d0 : $val) ==="

print_bit $val 12 "DDR_PUBL_APB_SOFT_RST"
print_bit $val 11 "DDR_UMCTL_APB_SOFT_RST"

print_bit $val 10 "DDR_PUBL_SOFT_RST"
print_bit $val 9 "DDR_UMCTL_SOFT_RST"
print_bit $val 8 "DDR_PHY_SOFT_RST"

print_bit $val 6 "DDR_PHY_AUTO_GATE_EN"
print_bit $val 5 "DDR_PUBL_AUTO_GATE_EN"
print_bit $val 4 "DDR_UMCTL_AUTO_GATE_EN"

print_bit $val 2 "DDR_PHY_SLEEP"
print_bit $val 1 "DDR_UMCTL_SLEEP"
print_bit $val 0 "DDR_PUBL_EB"
echo " "

##### SLEEP_STATUS
val=$(read_reg 0x402b0000 0xd4)
echo "=== SLEEP_STATUS(0x402b00d4 : $val) ==="

print_sleep_status_info $val 12 "CP2_SLP_STATUS"
print_sleep_status_info $val 8 "CP1_SLP_STATUS"
print_sleep_status_info $val 4 "CP0_SLP_STATUS"
print_sleep_status_info $val 0 "AP_SLP_STATUS"
echo " "


echo "=================================================================================="
echo " "
fi

if (($READ_DDR_FREQ & $FUNC_ENABLE)); then
echo "===============================  DDR freq  ================================="

function read_DDR_freq() {
	REG_AON_CLK_EMC_CFG=$($LOOKAT 0x402e0080|$TR -d '\r')
	REG_AON_APB_DPLL_CFG1=$($LOOKAT 0x402e3074|$TR -d '\r')

	clk_emc_sel=$(($REG_AON_CLK_EMC_CFG & 7))
	clk_emc_div=$(($REG_AON_CLK_EMC_CFG >> 8 & 0x7))
	dpll_nint=$(($REG_AON_APB_DPLL_CFG1&0x3f))
	dpll_kint=$((($REG_AON_APB_DPLL_CFG1 >> 12) & 0xfffff))

	ddr_freq=0
	refin=26
	ddr_pll="DPLL"

	
clk_src=$(($refin*$dpll_nint+$refin*$dpll_kint/1024/1024))
ddr_pll="DPLL"

	ddr_freq=$(($clk_src/(1+$clk_emc_div)/2))

	echo "REG_AON_CLK_EMC_CFG: $REG_AON_CLK_EMC_CFG"
	echo "REG_AON_APB_DPLL_CFG1: $REG_AON_APB_DPLL_CFG1"
	echo "----"
	echo "freq: $ddr_freq"
	echo "PLL: $ddr_pll"
}
read_DDR_freq



echo "====================read DDR releted memory values============================="
function print_ram_conent() {
	pin_add=$1
	pin_val=$2
	index=$3

	mod=$(($index%8))
#echo "$mod"

	if [ $mod = 0 ]; then
		echo " "
		echo -n "$pin_add: $pin_val"
	else
		echo -n "  $pin_val"
	fi
}

function print_ram_section() {
	reg_add=$1
	reg_len=$2

i=0
$LOOKAT -l $reg_len $reg_add | while read LINE
do
	is_hex=$(echo $LINE | $AWK '/0x/{print 1}')
	if [[ $is_hex ]]; then
		pin_add=$(echo $LINE | $AWK '{print $1}' | $SED 's/\r$//');
		pin_val=$(echo $LINE | $AWK '{print $3}' | $SED 's/\r$//');

		print_ram_conent $pin_add $pin_val $i
		((i++))
	fi
done
}

echo " "
echo "====================read DDR control 0x30000000--0x30000800======================="
print_ram_section 0x30000000 512
echo " "

echo " "
echo "====================read DDR control 0x300e3000--0x300e3100======================="
print_ram_section 0x300e3000 64
echo " "

echo " "
echo "====================read IRAM        0x1c00--0x1F00==============================="
print_ram_section 0x1c00 192
echo " "

echo " "
echo "====================read DDR Ret_info0x50000d80--0x50001500======================="
#0x5000000 can't print 480 registers at one time
iloop=0
begin_add=0x50000d80
add_len=320
while (( $iloop<6 ))
	do
		begin_add=$(hex $[$begin_add+$add_len*$iloop])
		print_ram_section $begin_add 80
		((iloop++))
	done
echo " "

echo "=================================================================================="
fi

if (($READ_XTL_INFO & $FUNC_ENABLE)); then
echo "===============================  xtl cfg  ================================="
##### XTL0_REL_CFG
val=$(read_reg 0x402b0000 0x80)
echo "=== XTL0_REL_CFG(0x402b0080 : $val) ==="

print_bit $val 3 "XTL0_CP2_SEL"
print_bit $val 2 "XTL0_CP1_SEL"
print_bit $val 1 "XTL0_CP0_SEL"
print_bit $val 0 "XTL0_AP_SEL"
echo " "

##### XTL1_REL_CFG
val=$(read_reg 0x402b0000 0x84)
echo "=== XTL1_REL_CFG(0x402b0084 : $val) ==="

print_bit $val 3 "XTL1_CP2_SEL"
print_bit $val 2 "XTL1_CP1_SEL"
print_bit $val 1 "XTL1_CP0_SEL"
print_bit $val 0 "XTL1_AP_SEL"
echo " "

##### XTL2_REL_CFG
val=$(read_reg 0x402b0000 0x88)
echo "=== XTL1_REL_CFG(0x402b0088 : $val) ==="

print_bit $val 3 "XTL2_CP2_SEL"
print_bit $val 2 "XTL2_CP1_SEL"
print_bit $val 1 "XTL2_CP0_SEL"
print_bit $val 0 "XTL2_AP_SEL"
echo " "

##### XTLBUF0_REL_CFG
val=$(read_reg 0x402b0000 0x8c)
echo "=== XTLBUF0_REL_CFG(0x402b008c : $val) ==="

print_bit $val 3 "XTLBUF0_CP2_SEL"
print_bit $val 2 "XTLBUF0_CP1_SEL"
print_bit $val 1 "XTLBUF0_CP0_SEL"
print_bit $val 0 "XTLBUF0_AP_SEL"
echo " "

##### XTLBUF1_REL_CFG
val=$(read_reg 0x402b0000 0x90)
echo "=== XTLBUF1_REL_CFG(0x402b0090 : $val) ==="

print_bit $val 3 "XTLBUF1_CP2_SEL"
print_bit $val 2 "XTLBUF1_CP1_SEL"
print_bit $val 1 "XTLBUF1_CP0_SEL"
print_bit $val 0 "XTLBUF1_AP_SEL"
echo " "

echo "=================================================================================="
echo " "
fi

if (($READ_PLL_SEL & $FUNC_ENABLE)); then
echo "===============================  pll cfg  ================================="


function print_sel_info_enter() {
	reg_val=$1
	reg_bit=$2
	reg_mask=$3
	src=$4
	arr=($5)

	echo -n "$src=>"
	index=$($PRINTF "%d" $(($reg_val >> $reg_bit & $reg_mask)))
	echo "${arr[$index]} "
}

##### MPLL_REL_CFG
val=$(read_reg 0x402b0000 0x94)
echo "=== MPLL_REL_CFG(0x402b0094 : $val) ==="

print_bit $val 4 "MPLL_SIN1_SEL"
print_bit $val 3 "MPLL_CP2_SEL"
print_bit $val 2 "MPLL_CP1_SEL"
print_bit $val 1 "MPLL_CP0_SEL"
print_bit $val 0 "MPLL_AP_SEL"
echo " "

##### DPLL_REL_CFG
val=$(read_reg 0x402b0000 0x98)
echo "=== DPLL_REL_CFG(0x402b0098 : $val) ==="

print_bit $val 4 "DPLL_SIN1_SEL"
print_bit $val 3 "DPLL_CP2_SEL"
print_bit $val 2 "DPLL_CP1_SEL"
print_bit $val 1 "DPLL_CP0_SEL"
print_bit $val 0 "DPLL_AP_SEL"
echo " "

##### TDPLL_REL_CFG
val=$(read_reg 0x402b0000 0x9c)
echo "=== TDPLL_REL_CFG(0x402b009c : $val) ==="

print_bit $val 4 "TDPLL_SIN1_SEL"
print_bit $val 3 "TDPLL_CP2_SEL"
print_bit $val 2 "TDPLL_CP1_SEL"
print_bit $val 1 "TDPLL_CP0_SEL"
print_bit $val 0 "TDPLL_AP_SEL"
echo " "

##### WPLL_REL_CFG
val=$(read_reg 0x402b0000 0xa0)
echo "=== WPLL_REL_CFG(0x402b00a0 : $val) ==="

print_bit $val 4 "WPLL_SIN1_SEL"
print_bit $val 3 "WPLL_CP2_SEL"
print_bit $val 2 "WPLL_CP1_SEL"
print_bit $val 1 "WPLL_CP0_SEL"
print_bit $val 0 "WPLL_AP_SEL"
echo " "

##### CPLL_REL_CFG
val=$(read_reg 0x402b0000 0xa4)
echo "=== CPLL_REL_CFG(0x402b00a4 : $val) ==="

print_bit $val 4 "CPLL_SIN1_SEL"
print_bit $val 3 "CPLL_CP2_SEL"
print_bit $val 2 "CPLL_CP1_SEL"
print_bit $val 1 "CPLL_CP0_SEL"
print_bit $val 0 "CPLL_AP_SEL"
echo " "

##### WIFIPLL1_REL_CFG
val=$(read_reg 0x402b0000 0xa8)
echo "=== WIFIPLL1_REL_CFG(0x402b00a4 : $val) ==="

print_bit $val 4 "WIFIPLL1_SIN1_SEL"
print_bit $val 3 "WIFIPLL1_CP2_SEL"
print_bit $val 2 "WIFIPLL1_CP1_SEL"
print_bit $val 1 "WIFIPLL1_CP0_SEL"
print_bit $val 0 "WIFIPLL1_AP_SEL"
echo " "

##### WIFIPLL2_REL_CFG
val=$(read_reg 0x402b0000 0xac)
echo "=== WIFIPLL2_REL_CFG(0x402b00a4 : $val) ==="

print_bit $val 4 "WIFIPLL2_SIN1_SEL"
print_bit $val 3 "WIFIPLL2_CP2_SEL"
print_bit $val 2 "WIFIPLL2_CP1_SEL"
print_bit $val 1 "WIFIPLL2_CP0_SEL"
print_bit $val 0 "WIFIPLL2_AP_SEL"
echo " "

##### 26M_SEL_CFG
val=$(read_reg 0x402b0000 0x134)
echo "=== 26M_SEL_CFG(0x402b0134 : $val) ==="

print_sel_info_enter $val 0 1 "AP_26M_SEL" "RF0 RF1"
print_sel_info_enter $val 1 1 "CP0_26M_SEL" "RF0 RF1"
print_sel_info_enter $val 2 1 "CP1_26M_SEL" "RF0 RF1"
print_sel_info_enter $val 3 1 "CP2_26M_SEL" "RF0 RF1"
print_sel_info_enter $val 4 1 "AON_26M_SEL" "RF0 RF1"
print_sel_info_enter $val 5 1 "PUB_26M_SEL" "RF0 RF1"
print_sel_info_enter $val 6 1 "LPLL_26M_SEL" "RF0 RF1"
print_sel_info_enter $val 7 1 "AON_MEM_PD_EN_AP aon memory powerdown care about AP status" "NO YES"
print_sel_info_enter $val 8 1 "AON_MEM_PD_EN_CP0 aon memory powerdown care about CP0 status" "NO YES"
print_sel_info_enter $val 9 1 "AON_MEM_PD_EN_CP1 aon memory powerdown care about CP1 status" "NO YES"
print_sel_info_enter $val 10 1 "AON_MEM_PD_EN_CP2 aon memory powerdown care about CP2 status" "NO YES"
print_sel_info_enter $val 7 1 "CLK26MHZ_REF_1_SEL=" "NO YES"
echo " "

echo "=================================================================================="
echo " "
fi


