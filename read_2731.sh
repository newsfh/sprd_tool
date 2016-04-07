
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

function bin_hex_print_chars() {
	value=$1
	vshift=$2
	vmask=$3
	strs=$4
	ret=$(($value >> $vshift & $vmask))
	echo -n $strs
	printf "0x%02x" $ret
	echo ""
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

function print_sel_info() {
	reg_val=$1
	reg_bit=$2
	reg_mask=$3
	src=$4
	arr=($5)

	echo -n "$src=>"
	index=$($PRINTF "%d" $(($reg_val >> $reg_bit & $reg_mask)))
	echo "${arr[$index]} "
}



echo "===============================  SC2731 common Status  ================================="
##### ANA_REG_GLB_CHIP_ID_LOW
val=$(read_reg 0x40038C00 0x0)
echo "=== ANA_REG_GLB_CHIP_ID_LOW(0x40038C00 : $val) ==="
##### ANA_REG_GLB_CHIP_ID_HIGH
val=$(read_reg 0x40038C00 0x4)
echo "=== ANA_REG_GLB_CHIP_ID_HIGH(0x40038C04 : $val) ==="

##### ANA_REG_GLB_MODULE_EN0
val=$(read_reg 0x40038C00 0x8)
echo "=== ANA_REG_GLB_MODULE_EN0(0x40038C08 : $val) ==="

print_bit $val 10 "THM_EN"
print_bit $val 9 "BLTC_EN"
print_bit $val 8 "PINREG_EN"
print_bit $val 7 "FGU_EN"
print_bit $val 6 "EFS_EN"
print_bit $val 5 "ADC_EN"
print_bit $val 4 "AUD_EN"
print_bit $val 3 "EIC_EN"
print_bit $val 2 "WDG_EN"
print_bit $val 1 "RTC_EN"
print_bit $val 0 "CAL_EN"

##### ANA_REG_GLB_MODULE_EN1
val=$(read_reg 0x40038C00 0xC)
echo "=== ANA_REG_GLB_MODULE_EN1(0x40038C0C : $val) ==="
print_bit $val 5 "SWITCH_CHG_EN"
print_bit $val 4 "BIF_EN"
print_bit $val 3 "TYPEC_EN"
print_bit $val 2 "CHG_WDG_EN"
print_bit $val 1 "TMR_EN"
print_bit $val 0 "FAST_CHG_EN"
echo " "

##### ANA_REG_GLB_ARM_CLK_EN0
val=$(read_reg 0x40038C00 0x10)
echo "=== ANA_REG_GLB_ARM_CLK_EN0(0x40038C10 : $val) ==="
print_sel_info $val 7 1 "CLK_AUD_SCLK_EN" "00:disable 01:enable"
print_sel_info $val 6 1 "CLK_AUXAD_EN" "00:disable 01:enable"
print_sel_info $val 5 1 "CLK_AUXADC_EN" "00:disable 01:enable"
print_sel_info $val 3 3 "CLK_CAL_SRC_SEL" "00:32K_less_1MHZ 01:DCDC_CLK2M_OUT 02:DCDC_CLK3M_OUT 03:NA"
print_sel_info $val 2 1 "CLK_CAL_EN" "00:disable 01:enable"
print_sel_info $val 1 1 "CLK_AUD_IF_6P5M_EN" "00:disable 01:enable"
print_sel_info $val 0 1 "CLK_AUD_IF_EN" "00:disable 01:enable"

##### ANA_REG_GLB_ARM_CLK_EN1
val=$(read_reg 0x40038C00 0x14)
echo "=== ANA_REG_GLB_ARM_CLK_EN1(0x40038C14 : $val) ==="
print_sel_info $val 0 1 "CLK_BIF_EN" "00:disable 01:enable"


##### ANA_REG_GLB_RTC_CLK_EN0
val=$(read_reg 0x40038C00 0x18)
echo "=== ANA_REG_GLB_RTC_CLK_EN0(0x40038C18 : $val) ==="
print_sel_info $val 12 1 "RTC_FLASH_EN" "00:disable 01:enable"
print_sel_info $val 11 1 "RTC_EFS_EN" "00:disable 01:enable"
print_sel_info $val 10 1 "RTC_THMA_AUTO_EN" "00:disable 01:enable"
print_sel_info $val 9 1 "RTC_THMA_EN" "00:disable 01:enable"
print_sel_info $val 8 1 "RTC_THM_EN" "00:disable 01:enable"
print_sel_info $val 7 1 "RTC_BLTC_EN" "00:disable 01:enable"
print_sel_info $val 6 1 "RTC_FGU_EN" "00:disable 01:enable"
print_sel_info $val 5 1 "RTC_FGUA_EN" "00:disable 01:enable"
print_sel_info $val 4 1 "RTC_VIBR_EN" "00:disable 01:enable"
print_sel_info $val 3 1 "RTC_EIC_EN" "00:disable 01:enable"
print_sel_info $val 2 1 "RTC_WDG_EN" "00:disable 01:enable"
print_sel_info $val 1 1 "RTC_RTC_EN" "00:disable 01:enable"
print_sel_info $val 0 1 "RTC_ARCH_EN" "00:disable 01:enable"

##### ANA_REG_GLB_RTC_CLK_EN1
val=$(read_reg 0x40038C00 0x1C)
echo "=== ANA_REG_GLB_RTC_CLK_EN1(0x40038C1C : $val) ==="
print_sel_info $val 4 1 "RTC_SWITCH_CHG_EN" "00:disable 01:enable"
print_sel_info $val 3 1 "RTC_TYPEC_EN" "00:disable 01:enable"
print_sel_info $val 2 1 "RTC_CHG_WDG_EN" "00:disable 01:enable"
print_sel_info $val 1 1 "RTC_TMR_EN" "00:disable 01:enable"
print_sel_info $val 0 1 "RTC_FAST_CHG_EN" "00:disable 01:enable"

echo " "

##### ANA_REG_GLB_SOFT_RST0
val=$(read_reg 0x40038C00 0x20)
echo "=== ANA_REG_GLB_SOFT_RST0(0x40038C20 : $val) ==="
print_bit $val 13 "AUDRX_SOFT_RST"
print_bit $val 12 "AUDTX_SOFT_RST"
print_bit $val 11 "THMA_SOFT_RST"
print_bit $val 10 "THM_SOFT_RST"
print_bit $val 9 "BLTC_SOFT_RST"
print_bit $val 8 "AUD_IF_SOFT_RST"
print_bit $val 7 "EFS_SOFT_RST"
print_bit $val 6 "ADC_SOFT_RST"
print_bit $val 5 "PWM0_SOFT_RST"
print_bit $val 4 "FGU_SOFT_RST"
print_bit $val 3 "EIC_SOFT_RST"
print_bit $val 2 "WDG_SOFT_RST"
print_bit $val 1 "RTC_SOFT_RST"
print_bit $val 0 "CAL_SOFT_RST"

##### ANA_REG_GLB_SOFT_RST1
val=$(read_reg 0x40038C00 0x24)
echo "=== ANA_REG_GLB_SOFT_RST1(0x40038C24 : $val) ==="
print_bit $val 5 "SWITCH_CHG_SOFT_RST"
print_bit $val 4 "BIF_SOFT_RST"
print_bit $val 3 "TYPEC_SOFT_RST"
print_bit $val 2 "CHG_WDG_SOFT_RST"
print_bit $val 1 "TMR_SOFT_RST"
print_bit $val 0 "FAST_CHG_SOFT_RST"
echo " "

echo "===============================  DCDC/LDO POWER ON/DOWN STATUS  ================================="
##### ANA_REG_GLB_POWER_PD_SW
val=$(read_reg 0x40038C00 0x28)
echo "=== ANA_REG_GLB_POWER_PD_SW(0x40038C28 : $val) ==="

print_bit $val 13 "LDO_DCXO_PD"
print_bit $val 12 "LDO_SRAM_PD"
print_bit $val 11 "DCDC_RF_PD"
print_bit $val 10 "LDO_EMM_PD"
print_bit $val 9 "DCDC_TOPCLK6M_PD"
print_bit $val 8 "DCDC_GEN_PD"
print_bit $val 7 "DCDC_MEM_PD"
print_bit $val 6 "DCDC_CORE_PD"
print_bit $val 5 "DCDC_GPU_PD"
print_bit $val 4 "DCDC_ARM0_PD"
print_bit $val 3 "DCDC_ARM1_PD"
print_bit $val 2 "LDO_AVDD18_PD"
print_bit $val 1 "LDO_VDD28_PD"
print_bit $val 0 "BG_PD"
	
#### ANA_REG_GLB_DCDC_GPU_PD_HW
val=$(read_reg 0x40038C00 0x0088)
print_sel_info $val 0 1 "DCDC_GPU_PD_HW" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_DCDC_WPA_REG2
val=$(read_reg 0x40038C00 0x00D4)
print_sel_info $val 13 1 "DCDC_WPA_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_CAMA0_REG0
val=$(read_reg 0x40038C00 0x00FC)
print_sel_info $val 0 1 "LDO_CAMA0_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_CAMA1_REG0
val=$(read_reg 0x40038C00 0x0104)
print_sel_info $val 0 1 "LDO_CAMA1_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_CAMMOT_REG0
val=$(read_reg 0x40038C00 0x010C)
print_sel_info $val 0 1 "LDO_CAMMOT_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_SIM0_PD_REG0
val=$(read_reg 0x40038C00 0x0164)
print_sel_info $val 0 1 "LDO_SIM0_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_SIM1_PD_REG0
val=$(read_reg 0x40038C00 0x0168)
print_sel_info $val 0 1 "LDO_SIM1_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_VLDO_PD_REG
val=$(read_reg 0x40038C00 0x016C)
print_sel_info $val 0 1 "LDO_VLDO_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_EMMCCORE_REG0
val=$(read_reg 0x40038C00 0x012C)
print_sel_info $val 0 1 "LDO_EMMCCORE_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_SD_PD_REG0
val=$(read_reg 0x40038C00 0x0174)
print_sel_info $val 0 1 "LDO_SDCORE_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_SDIO_PD_REG0
val=$(read_reg 0x40038C00 0x0170)
print_sel_info $val 0 1 "LDO_SDIO_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_WIFIPA_REG0
val=$(read_reg 0x40038C00 0x0147)
print_sel_info $val 0 1 "LDO_WIFIPA_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_USB33_REG0
val=$(read_reg 0x40038C00 0x015C)
print_sel_info $val 0 1 "LDO_USB33_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_CAMD0_REG0
val=$(read_reg 0x40038C00 0x017C)
print_sel_info $val 0 1 "LDO_CAMD0_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_CAMD1_REG0
val=$(read_reg 0x40038C00 0x0184)
print_sel_info $val 0 1 "LDO_CAMD1_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_CON_REG0
val=$(read_reg 0x40038C00 0x018C)
print_sel_info $val 0 1 "LDO_CON_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_CAMIO_REG0
val=$(read_reg 0x40038C00 0x0194)
print_sel_info $val 0 1 "LDO_CAMIO_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_LDO_VDDRF_REG0
val=$(read_reg 0x40038C00 0x01A4)
print_sel_info $val 0 1 "LDO_RF_PD" "00:POWER_ON 01:POWER_DOWN"
#### ANA_REG_GLB_CHGR_DET_FGU_CTRL
val=$(read_reg 0x40038C00 0x02D8)
print_sel_info $val 12 1 "LDO_FGU_PD" "00:Normal_mode 01:POWER_DOWN"

echo " "


echo "===============================  DCDC/LDO SLEEP STATUS CONFIG  ================================="
#### ANA_REG_GLB_SLP_CTRL
val=$(read_reg 0x40038C00 0x1F0)
echo "=== ANA_REG_GLB_SLP_CTRL(0x40038DF0 : $val) ==="

print_bit $val 3 "LDO_XTL_EN: LDO/DCDC can be controlled by externel device"
print_bit $val 2 "SLP_BG_LP_EN: Band gap low power in deep sleep"
print_bit $val 1 "SLP_IO_EN: IO Pad sleep in deep sleep"
print_bit $val 0 "SLEEP_LDO_PD_EN: ALL LDO/DCDC power down in deep sleep"
echo " "

##### ANA_REG_GLB_SLP_DCDC_PD_CTRL
val=$(read_reg 0x40038C00 0x1F4)
echo "=== ANA_REG_GLB_SLP_DCDC_PD_CTRL(0x40038DF4 : $val) ==="

print_bit $val 9 "BIT_SLP_DCDCGPU_PD_EN"
print_bit $val 8 "BIT_SLP_DCDCGPU_DROP_EN"
print_bit $val 7 "BIT_SLP_DCDCCORE_DROP_EN"
print_bit $val 6 "BIT_SLP_DCDCRF_PD_EN"
print_bit $val 3 "BIT_SLP_DCDCWPA_PD_EN"
print_bit $val 2 "BIT_SLP_DCDCARM0_PD_EN"
print_bit $val 1 "BIT_SLP_DCDCARM1_PD_EN"
print_bit $val 0 "BIT_SLP_DCDCMEM_PD_EN"
echo " "

##### ANA_REG_GLB_SLP_LDO_PD_CTRL0
val=$(read_reg 0x40038C00 0x1F8)
echo "=== ANA_REG_GLB_SLP_LDO_PD_CTRL0(0x40038DF8 : $val) ==="

print_bit $val 15 "BIT_SLP_LDORF0_PD_EN"
print_bit $val 14 "BIT_SLP_LDOEMMCCORE_PD_EN"
print_bit $val 13 "BIT_SLP_LDODCXO_PD_EN"
print_bit $val 12 "BIT_SLP_LDOWIFIPA_PD_EN"
print_bit $val 11 "BIT_SLP_LDOVDD28_PD_EN"
print_bit $val 10 "BIT_SLP_LDOSDCORE_PD_EN"
print_bit $val 9 "BIT_SLP_LDOSDIO_PD_EN"
print_bit $val 8 "BIT_SLP_LDOUSB33_PD_EN"
print_bit $val 7 "BIT_SLP_LDOCAMMOT_PD_EN"
print_bit $val 6 "BIT_SLP_LDOCAMIO_PD_EN"
print_bit $val 5 "BIT_SLP_LDOCAMD0_PD_EN"
print_bit $val 4 "BIT_SLP_LDOCAMD1_PD_EN"
print_bit $val 3 "BIT_SLP_LDOCAMA0_PD_EN"
print_bit $val 2 "BIT_SLP_LDOCAMA1_PD_EN"
print_bit $val 1 "BIT_SLP_VLDO_PD_EN"
print_bit $val 0 "BIT_SLP_LDOSIM1_PD_EN"
echo " "

##### ANA_REG_GLB_SLP_LDO_PD_CTRL1
val=$(read_reg 0x40038C00 0x1FC)
echo "=== ANA_REG_GLB_SLP_LDO_PD_CTRL1(0x40038DFC : $val) ==="

print_bit $val 3 "BIT_SLP_LDOCON_PD_EN"
print_bit $val 2 "BIT_SLP_LDOSIM0_PD_EN"
print_bit $val 1 "BIT_SLP_LDOAVDD18_PD_EN"
print_bit $val 0 "BIT_SLP_LDOSRAM_PD_EN"
echo " "

##### ANA_REG_GLB_SLP_DCDC_LP_CTRL
val=$(read_reg 0x40038C00 0x200)
echo "=== ANA_REG_GLB_SLP_DCDC_LP_CTRL(0x40038E00 : $val) ==="

print_bit $val 8 "BIT_SLP_DCDCRF_LP_EN"
#print_bit $val 7 ""
print_bit $val 6 "SLP_LDOEMMCCORE_LP_EN"
print_bit $val 5 "BIT_SLP_DCDCGPU_LP_EN"
print_bit $val 4 "BIT_SLP_DCDCMEM_LP_EN"
print_bit $val 3 "BIT_SLP_DCDCARM1_LP_EN"
print_bit $val 2 "BIT_SLP_DCDCARM0_LP_EN"
print_bit $val 1 "BIT_SLP_DCDCGEN_LP_EN"
print_bit $val 0 "BIT_SLP_DCDCWPA_LP_EN"
echo " "

##### ANA_REG_GLB_SLP_LDO_LP_CTRL0
val=$(read_reg 0x40038C00 0x204)
echo "=== ANA_REG_GLB_SLP_LDO_LP_CTRL0(0x40038E04 : $val) ==="

print_bit $val 15 "BIT_SLP_LDORF0_LP_EN"
print_bit $val 14 "BIT_SLP_LDOEMMCCORE_LP_EN"
print_bit $val 13 "BIT_SLP_LDODCXO_LP_EN"
print_bit $val 12 "BIT_SLP_LDOWIFIPA_LP_EN"
print_bit $val 11 "BIT_SLP_LDOVDD28_LP_EN"
print_bit $val 10 "BIT_SLP_LDOSDCORE_LP_EN"
print_bit $val 9 "BIT_SLP_LDOSDIO_LP_EN"
print_bit $val 8 "BIT_SLP_LDOUSB33_LP_EN"
print_bit $val 7 "BIT_SLP_LDOCAMMOT_LP_EN"
print_bit $val 6 "BIT_SLP_LDOCAMIO_LP_EN"
print_bit $val 5 "BIT_SLP_LDOCAMD0_LP_EN"
print_bit $val 4 "BIT_SLP_LDOCAMD1_LP_EN"
print_bit $val 3 "BIT_SLP_LDOCAMA0_LP_EN"
print_bit $val 2 "BIT_SLP_LDOCAMA1_LP_EN"
print_bit $val 1 "BIT_SLP_VLDO_LP_EN"
print_bit $val 0 "BIT_SLP_LDOSIM1_LP_EN"
echo " "

##### ANA_REG_GLB_SLP_LDO_LP_CTRL1
val=$(read_reg 0x40038C00 0x208)
echo "=== ANA_REG_GLB_SLP_LDO_LP_CTRL1(0x40038E08 : $val) ==="

print_bit $val 3 "BIT_SLP_LDOCON_LP_EN"
print_bit $val 2 "BIT_SLP_LDOSIM0_LP_EN"
print_bit $val 1 "BIT_SLP_LDOAVDD18_LP_EN"
print_bit $val 0 "BIT_SLP_LDOSRAM_LP_EN"
echo " "

echo "=== print core/gpu sleep control ==="
##### ANA_REG_GLB_DCDC_CORE_SLP_CTRL GROUP
val=$(read_reg 0x40038C00 0x020C)
echo "=== ANA_REG_GLB_DCDC_CORE_SLP_CTRL0(0x40038E0C : $val) ==="
val=$(read_reg 0x40038C00 0x0210)
echo "=== ANA_REG_GLB_DCDC_CORE_SLP_CTRL1(0x40038E10 : $val) ==="
val=$(read_reg 0x40038C00 0x0214)
echo "=== ANA_REG_GLB_DCDC_CORE_SLP_CTRL2(0x40038E14 : $val) ==="
val=$(read_reg 0x40038C00 0x0218)
echo "=== ANA_REG_GLB_DCDC_CORE_SLP_CTRL3(0x40038E18 : $val) ==="
val=$(read_reg 0x40038C00 0x021C)
echo "=== ANA_REG_GLB_DCDC_CORE_SLP_CTRL4(0x40038E1C : $val) ==="
val=$(read_reg 0x40038C00 0x0220)
echo "=== ANA_REG_GLB_DCDC_CORE_SLP_CTRL5(0x40038E20 : $val) ==="

##### ANA_REG_GLB_DCDC_GPU_SLP_CTRL GROUP
val=$(read_reg 0x40038C00 0x0224)
echo "=== ANA_REG_GLB_DCDC_GPU_SLP_CTRL0(0x40038E24 : $val) ==="
val=$(read_reg 0x40038C00 0x0228)
echo "=== ANA_REG_GLB_DCDC_GPU_SLP_CTRL1(0x40038E28 : $val) ==="
val=$(read_reg 0x40038C00 0x022C)
echo "=== ANA_REG_GLB_DCDC_GPU_SLP_CTRL2(0x40038E2C : $val) ==="
val=$(read_reg 0x40038C00 0x0230)
echo "=== ANA_REG_GLB_DCDC_GPU_SLP_CTRL3(0x40038E30 : $val) ==="
val=$(read_reg 0x40038C00 0x0234)
echo "=== ANA_REG_GLB_DCDC_GPU_SLP_CTRL4(0x40038E34 : $val) ==="
val=$(read_reg 0x40038C00 0x0238)
echo "=== ANA_REG_GLB_DCDC_GPU_SLP_CTRL5(0x40038E38 : $val) ==="


##### ANA_REG_GLB_DCDC_XTL_EN0
val=$(read_reg 0x40038C00 0x023C)
echo "=== ANA_REG_GLB_DCDC_XTL_EN0(0x40038E3C : $val) ==="

print_bit $val 15 "BIT_DCDC_CORE_EXT_XTL0_EN"
print_bit $val 14 "BIT_DCDC_CORE_EXT_XTL1_EN"
print_bit $val 13 "BIT_DCDC_CORE_EXT_XTL2_EN"
print_bit $val 12 "BIT_DCDC_CORE_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_DCDC_GPU_EXT_XTL0_EN"
print_bit $val 2 "BIT_DCDC_GPU_EXT_XTL1_EN"
print_bit $val 1 "BIT_DCDC_GPU_EXT_XTL2_EN"
print_bit $val 0 "BIT_DCDC_GPU_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_DCDC_XTL_EN1
val=$(read_reg 0x40038C00 0x0240)
echo "=== ANA_REG_GLB_DCDC_XTL_EN1(0x40038E40 : $val) ==="

print_bit $val 15 "BIT_DCDC_ARM0_EXT_XTL0_EN"
print_bit $val 14 "BIT_DCDC_ARM0_EXT_XTL1_EN"
print_bit $val 13 "BIT_DCDC_ARM0_EXT_XTL2_EN"
print_bit $val 12 "BIT_DCDC_ARM0_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_DCDC_ARM1_EXT_XTL0_EN"
print_bit $val 2 "BIT_DCDC_ARM1_EXT_XTL1_EN"
print_bit $val 1 "BIT_DCDC_ARM1_EXT_XTL2_EN"
print_bit $val 0 "BIT_DCDC_ARM1_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_DCDC_XTL_EN2
val=$(read_reg 0x40038C00 0x0244)
echo "=== ANA_REG_GLB_DCDC_XTL_EN2(0x40038E44 : $val) ==="

print_bit $val 15 "BIT_DCDC_MEM_EXT_XTL0_EN"
print_bit $val 14 "BIT_DCDC_MEM_EXT_XTL1_EN"
print_bit $val 13 "BIT_DCDC_MEM_EXT_XTL2_EN"
print_bit $val 12 "BIT_DCDC_MEM_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_DCDC_GEN_EXT_XTL0_EN"
print_bit $val 2 "BIT_DCDC_GEN_EXT_XTL1_EN"
print_bit $val 1 "BIT_DCDC_GEN_EXT_XTL2_EN"
print_bit $val 0 "BIT_DCDC_GEN_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_DCDC_XTL_EN3
val=$(read_reg 0x40038C00 0x0248)
echo "=== ANA_REG_GLB_DCDC_XTL_EN3(0x40038E48 : $val) ==="

print_bit $val 15 "BIT_DCDC_RF_EXT_XTL0_EN"
print_bit $val 14 "BIT_DCDC_RF_EXT_XTL1_EN"
print_bit $val 13 "BIT_DCDC_RF_EXT_XTL2_EN"
print_bit $val 12 "BIT_DCDC_RF_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_DCDC_WPA_EXT_XTL0_EN"
print_bit $val 2 "BIT_DCDC_WPA_EXT_XTL1_EN"
print_bit $val 1 "BIT_DCDC_WPA_EXT_XTL2_EN"
print_bit $val 0 "BIT_DCDC_WPA_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN0
val=$(read_reg 0x40038C00 0x0250)
echo "=== ANA_REG_GLB_LDO_XTL_EN0(0x40038E50 : $val) ==="

print_bit $val 15 "BIT_LDO_DCXO_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_DCXO_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_DCXO_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_DCXO_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_VDD28_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_VDD28_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_VDD28_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_VDD28_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN1
val=$(read_reg 0x40038C00 0x0254)
echo "=== ANA_REG_GLB_LDO_XTL_EN1(0x40038E54 : $val) ==="

print_bit $val 15 "BIT_LDO_SDIO_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_SDIO_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_SDIO_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_SDIO_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_WIFIPA_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_WIFIPA_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_WIFIPA_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_WIFIPA_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN2
val=$(read_reg 0x40038C00 0x0258)
echo "=== ANA_REG_GLB_LDO_XTL_EN2(0x40038E58 : $val) ==="

print_bit $val 15 "BIT_LDO_SIM0_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_SIM0_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_SIM0_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_SIM0_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_SIM1_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_SIM1_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_SIM1_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_SIM1_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN3
val=$(read_reg 0x40038C00 0x025C)
echo "=== ANA_REG_GLB_LDO_XTL_EN3(0x40038E5C : $val) ==="

print_bit $val 15 "BIT_LDO_VLDO_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_VLDO_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_VLDO_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_VLDO_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_SRAM_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_SRAM_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_SRAM_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_SRAM_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN4
val=$(read_reg 0x40038C00 0x0260)
echo "=== ANA_REG_GLB_LDO_XTL_EN4(0x40038E60 : $val) ==="

print_bit $val 15 "BIT_LDO_CAMMOT_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_CAMMOT_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_CAMMOT_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_CAMMOT_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_CAMIO_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_CAMIO_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_CAMIO_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_CAMIO_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN5
val=$(read_reg 0x40038C00 0x0264)
echo "=== ANA_REG_GLB_LDO_XTL_EN5(0x40038E64 : $val) ==="

print_bit $val 15 "BIT_LDO_CAMA0_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_CAMA0_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_CAMA0_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_CAMA0_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_CAMA1_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_CAMA1_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_CAMA1_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_CAMA1_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN6
val=$(read_reg 0x40038C00 0x0268)
echo "=== ANA_REG_GLB_LDO_XTL_EN6(0x40038E68 : $val) ==="

print_bit $val 15 "BIT_LDO_CAMD0_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_CAMD0_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_CAMD0_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_CAMD0_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_CAMD1_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_CAMD1_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_CAMD1_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_CAMD1_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN7
val=$(read_reg 0x40038C00 0x026C)
echo "=== ANA_REG_GLB_LDO_XTL_EN7(0x40038E6C : $val) ==="

print_bit $val 15 "BIT_LDO_SDIO_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_SDIO_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_SDIO_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_SDIO_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_SDCORE_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_SDCORE_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_SDCORE_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_SDCORE_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN8
val=$(read_reg 0x40038C00 0x0270)
echo "=== ANA_REG_GLB_LDO_XTL_EN8(0x40038E70 : $val) ==="

print_bit $val 15 "BIT_LDO_EMMCCORE_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_EMMCCORE_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_EMMCCORE_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_EMMCCORE_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_USB33_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_USB33_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_USB33_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_USB33_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN9
val=$(read_reg 0x40038C00 0x0274)
echo "=== ANA_REG_GLB_LDO_XTL_EN9(0x40038E74 : $val) ==="

print_bit $val 15 "BIT_LDO_KPLED_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_KPLED_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_KPLED_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_KPLED_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_VIBR_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_VIBR_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_VIBR_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_VIBR_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_LDO_XTL_EN10
val=$(read_reg 0x40038C00 0x0278)
echo "=== ANA_REG_GLB_LDO_XTL_EN10(0x40038E78 : $val) ==="

print_bit $val 15 "BIT_LDO_CON_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_CON_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_CON_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_CON_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_AVDD18_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_AVDD18_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_AVDD18_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_AVDD18_EXT_XTL3_EN"
echo " "

##### ANA_REG_GLB_XO_BG_XTL_EN
val=$(read_reg 0x40038C00 0x027C)
echo "=== ANA_REG_GLB_XO_BG_XTL_EN(0x40038E7C : $val) ==="

print_bit $val 15 "BIT_LDO_XO_EXT_XTL0_EN"
print_bit $val 14 "BIT_LDO_XO_EXT_XTL1_EN"
print_bit $val 13 "BIT_LDO_XO_EXT_XTL2_EN"
print_bit $val 12 "BIT_LDO_XO_EXT_XTL3_EN"
#print_bit $val 11 ""
#print_bit $val 10 ""
#print_bit $val 9 ""
#print_bit $val 8 ""
#print_bit $val 7 ""
#print_bit $val 6 ""
#print_bit $val 5 ""
#print_bit $val 4 ""
print_bit $val 3 "BIT_LDO_BG_EXT_XTL0_EN"
print_bit $val 2 "BIT_LDO_BG_EXT_XTL1_EN"
print_bit $val 1 "BIT_LDO_BG_EXT_XTL2_EN"
print_bit $val 0 "BIT_LDO_BG_EXT_XTL3_EN"
echo " "


echo "===============================  DCDC/LDO SELECT  ================================="
##### ANA_REG_GLB_DCDC_VLG_SEL
val=$(read_reg 0x40038C00 0x0298)
echo "=== ANA_REG_GLB_DCDC_VLG_SEL(0x40038E98 : $val) ==="
print_sel_info $val 0 1 "BIT_DCDC_VREF_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 1 1 "BIT_DCDC_WPA_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 2 1 "BIT_DCDC_RF_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 3 1 "BIT_DCDC_GEN_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 4 1 "BIT_DCDC_MEM_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 5 1 "BIT_DCDC_ARM1_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 6 1 "BIT_DCDC_ARM0_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 7 1 "BIT_DCDC_GPU_SLP_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 8 1 "BIT_DCDC_GPU_NOR_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 9 1 "BIT_DCDC_CORE_SLP_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 10 1 "BIT_DCDC_CORE_NOR_SW_SEL" "EMM SOFTWARE"

##### ANA_REG_GLB_DCDC_VLG_SEL0
val=$(read_reg 0x40038C00 0x029C)
echo "=== ANA_REG_GLB_DCDC_VLG_SEL0(0x40038E9C : $val) ==="
print_sel_info $val 0 1 "BIT_LDO_CAMD1_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 1 1 "BIT_LDO_CAMD0_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 2 1 "BIT_LDO_CAMA1_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 3 1 "BIT_LDO_CAMA0_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 4 1 "BIT_LDO_CAMIO_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 5 1 "BIT_LDO_CAMMOT_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 6 1 "BIT_LDO_SDIO_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 7 1 "BIT_LDO_SDCORE_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 8 1 "BIT_LDO_DCXO_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 9 1 "BIT_LDO_VDD28_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 10 1 "BIT_LDO_AVDD18_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 11 1 "BIT_LDO_EMMCCORE_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 12 1 "BIT_LDO_USB33_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 13 1 "BIT_LDO_RF0_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 14 1 "BIT_LDO_SIM1_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 15 1 "BIT_LDO_SIM0_SW_SEL" "EMM SOFTWARE"

##### ANA_REG_GLB_DCDC_VLG_SEL1
val=$(read_reg 0x40038C00 0x02A0)
echo "=== ANA_REG_GLB_DCDC_VLG_SEL1(0x40038EA0 : $val) ==="
print_sel_info $val 0 1 "BIT_LDO_VLDO_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 1 1 "BIT_LDO_SRAM_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 2 1 "BIT_LDO_WIFIPA_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 3 1 "BIT_LDO_CON_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 4 1 "BIT_LDO_VIBR_SW_SEL" "EMM SOFTWARE"
print_sel_info $val 5 1 "BIT_LDO_KPLED_SW_SEL" "EMM SOFTWARE"

echo "===============================  CLK32k LESS CTRL  ================================="
##### ANA_REG_GLB_CLK32KLESS_CTRL0
val=$(read_reg 0x40038C00 0x02A4)
echo "=== ANA_REG_GLB_CLK32KLESS_CTRL0(0x40038EA4 : $val) ==="
##### ANA_REG_GLB_CLK32KLESS_CTRL1
val=$(read_reg 0x40038C00 0x02A8)
echo "=== ANA_REG_GLB_CLK32KLESS_CTRL1(0x40038EA8 : $val) ==="
##### ANA_REG_GLB_CLK32KLESS_CTRL2
val=$(read_reg 0x40038C00 0x02AC)
echo "=== ANA_REG_GLB_CLK32KLESS_CTRL2(0x40038EAC : $val) ==="
##### ANA_REG_GLB_CLK32KLESS_CTRL3
val=$(read_reg 0x40038C00 0x02B0)
echo "=== ANA_REG_GLB_CLK32KLESS_CTRL3(0x40038EB0 : $val) ==="
##### ANA_REG_GLB_AUXAD_CTL
val=$(read_reg 0x40038C00 0x02B4)
echo "=== ANA_REG_GLB_AUXAD_CTL(0x40038EB4 : $val) ==="
echo ""


##### ANA_REG_GLB_XTL_WAIT_CTRL
val=$(read_reg 0x40038C00 0x02B8)
echo "=== ANA_REG_GLB_XTL_WAIT_CTRL(0x40038EB8 : $val) ==="

#print_bit $val 15 ""
print_sel_info $val 14 1 "CUR_SEL" "LOW HIGH"
print_bit $val 13 "26M WAKE UP BY XTL3"
print_bit $val 12 "26M WAKE UP BY XTL2"
print_bit $val 11 "26M WAKE UP BY XTL1"
print_bit $val 10 "26M WAKE UP BY XTL0"
print_bit $val 9 "26M power down in deep"
print_sel_info $val 8 1 "XTL_EN" "DISAB ENABLE"
bin_hex_print_chars $val 0 0xFF "XTL_WAIT="
echo " "

##### ANA_REG_GLB_RGB_CTRL
val=$(read_reg 0x40038C00 0x02BC)
echo "=== ANA_REG_GLB_RGB_CTRL(0x40038EBC : $val) ==="

print_bit $val 15 "BIT_RTC_PWM0_EN"
print_bit $val 14 "BIT_PWM0_EN"
#print_bit $val 13 ""
print_bit $val 12 "BIT_IB_REX_EN"
print_bit $val 11 "BIT_IB_TRIM_EM_SEL"
#print_bit $val 10 ""
#print_bit $val 9 ""
bin_hex_print_chars $val 4 0x1F "RGB_V="
#print_bit $val 3 ""
print_bit $val 2 "BIT_SLP_RGB_PD_EN"
print_bit $val 1 "BIT_RGB_PD_HW_EN"
print_bit $val 0 "BIT_RGB_PD_SW"
echo " "

##### ANA_REG_GLB_WHTLED_CTRL
val=$(read_reg 0x40038C00 0x02C0)
echo "=== ANA_REG_GLB_WHTLED_CTRL(0x40038EC0 : $val) ==="

bin_hex_print_chars $val 9 0x7F "IB_TRIM="
print_bit $val 8 "BIT_WHTLED_SERIES_EN"
print_bit $val 7 "BIT_WHTLED_PD_SEL"
bin_hex_print_chars $val 1 0x3F "WHITED_V="
print_bit $val 0 "BIT_WHTLED_PD"
echo " "

##### ANA_REG_GLB_KPLED_CTRL
val=$(read_reg 0x40038C00 0x02C4)
echo "=== ANA_REG_GLB_KPLED_CTRL(0x40038EC4 : $val) ==="

bin_hex_print_chars $val 12 0xF "KPLED_V="
print_bit $val 11 "BIT_KPLED_PD"
print_bit $val 10 "BIT_KPLED_PULLDOWN_EN"
print_bit $val 9 "BIT_SLP_LDOKPLED_PD_EN"
print_bit $val 8 "BIT_LDO_KPLED_PD"
bin_hex_print_chars $val 0 0xFF "LDO_KPLED_V="
echo " "

##### ANA_REG_GLB_VIBR_CTRL0
val=$(read_reg 0x40038C00 0x02C8)
echo "=== ANA_REG_GLB_VIBR_CTRL0(0x40038EC8 : $val) ==="

print_bit $val 15 "BIT_LDO_KPLED_SHPT_PD"
#print_bit $val 14 ""
print_sel_info $val 12 3 "CUR_DRV_CAL_SEL" "00-nooutput 01-nooutput 02-vib-cal 03-kpled-cal"
#bin_hex_print_chars $val 12 0x3 "CUR_DRV_CAL_SEL="
print_bit $val 11 "BIT_VIBR_PULLDOWN_EN"
print_bit $val 10 "BIT_VIBR_PULLUP_EN"
print_bit $val 9 "BIT_SLP_LDOVIBR_PD_EN"
print_bit $val 8 "BIT_LDO_VIBR_PD"
bin_hex_print_chars $val 0 0xFF "LDO_VIBR_V="
echo " "

##### ANA_REG_GLB_VIBR_CTRL1
val=$(read_reg 0x40038C00 0x02CC)
echo "=== ANA_REG_GLB_VIBR_CTRL1(0x40038ECC : $val) ==="

#print_bit $val 15 ""
#print_bit $val 14 ""
bin_hex_print_chars $val 7 0x1F "LDO_KPLED_REFTRIM="
print_bit $val 6 "BIT_LDO_KPLED_EADBIAS_EN"
bin_hex_print_chars $val 1 0x1F "LDO_VIBR_REFTRIM="
print_bit $val 0 "BIT_LDO_VIBR_EADBIAS_EN"
echo " "

##### ANA_REG_GLB_AUDIO_CTRL0
val=$(read_reg 0x40038C00 0x02D0)
echo "=== ANA_REG_GLB_AUDIO_CTRL0(0x40038ED0 : $val) ==="

print_bit $val 15 "BIT_AUD_SLP_APP_RST_EN"
bin_hex_print_chars $val 8 0x1F "CLK_AUD_HBD_DIV="
print_bit $val 4 "BIT_CLK_AUD_LOOP_INV_EN"
print_bit $val 3 "BIT_CLK_AUD_IF_TX_INV_EN"
print_bit $val 2 "BIT_CLK_AUD_IF_RX_INV_EN"
print_bit $val 1 "BIT_CLK_AUD_IF_6P5M_TX_INV_EN"
print_bit $val 0 "BIT_CLK_AUD_IF_6P5M_RX_INV_EN"
echo " "

##### ANA_REG_GLB_AUDIO_CTRL1
val=$(read_reg 0x40038C00 0x02D4)
echo "=== ANA_REG_GLB_AUDIO_CTRL1(0x40038ED4 : $val) ==="

print_bit $val 6 "BIT_HEAD_INSERT_EIC_EN"
print_bit $val 5 "BIT_AUDIO_CHP_CLK_DIV_EN"
bin_hex_print_chars $val 0 0x1F "AUDIO_CHP_CLK_DIV="
echo " "

##### ANA_REG_GLB_CHGR_DET_FGU_CTRL
val=$(read_reg 0x40038C00 0x02D8)
echo "=== ANA_REG_GLB_CHGR_DET_FGU_CTRL(0x40038ED8 : $val) ==="

print_bit $val 13 "BIT_FGUA_SOFT_RST"
print_sel_info $val 12 1 "LDO_FGU_PD" "00-normal_mode 01-power_down_mode"
bin_hex_print_chars $val 9 0x7 "CHG_INT_DELAY=64msx"
print_bit $val 8 "BIT_SD_CHOP_CAP_EN"
bin_hex_print_chars $val 6 0x3 "SD_CLK_P="
print_bit $val 5 "BIT_SD_DCOFFSET_EN"
print_bit $val 4 "BIT_SD_CHOP_EN"
#print_bit $val 3 ""
print_sel_info $val 2 1 "DP_DM_FC_ENB" "00-INVALID 01-switch_on_fast_charger_detect_disable"
print_sel_info $val 1 1 "DP_DM_AUX_EN" "00-switch_off_no_dp_dm_to_auxdc 01-switch_on_dp_dm_to_auxdc"
print_sel_info $val 0 1 "DP_DM_BC_ENB" "00-INVALID 01-switch_on_bc1p2_disable"
echo " "

##### ANA_REG_GLB_CHGR_STATUS
val=$(read_reg 0x40038C00 0x02DC)
echo "=== ANA_REG_GLB_CHGR_STATUS(0x40038EDC : $val) ==="

print_bit $val 13 "BIT_CHGR_INT_EN"
print_bit $val 12 "BIT_NON_DCP_INT"
print_bit $val 11 "BIT_CHG_DET_DONE"
print_bit $val 10 "BIT_DP_LOW"
print_bit $val 9 "BIT_DCP_DET"
print_bit $val 8 "BIT_CHG_DET"
print_bit $val 7 "BIT_SDP_INT"
print_bit $val 6 "BIT_DCP_INT"
print_bit $val 5 "BIT_CDP_INT"
print_bit $val 4 "BIT_CHGR_CV_STATUS"
print_bit $val 3 "BIT_CHGR_ON"
print_bit $val 2 "BIT_CHGR_INT"
print_bit $val 1 "BIT_VBAT_OVI"
print_bit $val 0 "BIT_VCHG_OVI"
echo " "

##### ANA_REG_GLB_MIXED_CTRL0
val=$(read_reg 0x40038C00 0x02E0)
echo "=== ANA_REG_GLB_MIXED_CTRL0(0x40038EE0 : $val) ==="

print_bit $val 13 "BIT_FGUA_SOFT_RST"
print_sel_info $val 12 1 "LDO_FGU_PD" "00-normal_mode 01-power_down_mode"
bin_hex_print_chars $val 9 0x7 "CHG_INT_DELAY=64msx"
print_bit $val 8 "BIT_SD_CHOP_CAP_EN"
bin_hex_print_chars $val 6 0x3 "SD_CLK_P="
print_bit $val 5 "BIT_SD_DCOFFSET_EN"
print_bit $val 4 "BIT_SD_CHOP_EN"
#print_bit $val 3 ""
print_sel_info $val 4 1 "DP_DM_FC_ENB" "00-INVALID 01-switch_on_fast_charger_detect_disable"
print_sel_info $val 2 3 "DP_DM_AUX_EN" "00:5.0V 01:5.2V 02:4.8V 03:4.2V"
print_sel_info $val 0 3 "OVLO_T" "00:1ms 01:0.5ms 02:0.25ms 03:2ms"
echo " "

##### ANA_REG_GLB_MIXED_CTRL1
val=$(read_reg 0x40038C00 0x02E4)
echo "=== ANA_REG_GLB_MIXED_CTRL1(0x40038EE4 : $val) ==="

bin_hex_print_chars $val 12 0xF "BITS_XOSC32K_CTL="
print_sel_info $val 10 3 "BITS_BATON_T" "00:32us_default 01:64us 02:128us 03:no_de_glitch"
print_sel_info $val 9 1 "BIT_BATDET_LDO_SEL" "00-ldo1 01-ldo2"
print_bit $val 8 "BIT_BATDET_LDO_SEL"
print_bit $val 7 "BIT_THM_CHIP_PD_FLAG"
print_bit $val 6 "BIT_THM_CHIP_PD_FLAG_CLR"
bin_hex_print_chars $val 5 0x3 "BITS_THM_CAL_SEL="
print_bit $val 4 "BIT_THM_AUTO_PD_EN"
print_bit $val 3 "BIT_ALL_GPI_DEB"
print_bit $val 2 "BIT_GPI_DEBUG_EN"
print_bit $val 1 "BIT_ALL_INT_DEB"
print_bit $val 0 "BIT_INT_DEBUG_EN"
echo " "



##### ANA_REG_GLB_POR_RST_MONITOR
val=$(read_reg 0x40038C00 0x02E8)
echo "=== ANA_REG_GLB_POR_RST_MONITOR(0x40038EE8 : $val) ==="
##### ANA_REG_GLB_WDG_RST_MONITOR
val=$(read_reg 0x40038C00 0x02EC)
echo "=== ANA_REG_GLB_WDG_RST_MONITOR(0x40038EEC : $val) ==="
##### ANA_REG_GLB_POR_PIN_RST_MONITOR
val=$(read_reg 0x40038C00 0x02F0)
echo "=== ANA_REG_GLB_POR_PIN_RST_MONITOR(0x40038EF0 : $val) ==="
##### ANA_REG_GLB_POR_SRC_FLAG
val=$(read_reg 0x40038C00 0x02F4)
echo "=== ANA_REG_GLB_POR_SRC_FLAG(0x40038EF4 : $val) ==="

##### ANA_REG_GLB_POR_7S_CTRL
val=$(read_reg 0x40038C00 0x02F8)
echo "=== ANA_REG_GLB_POR_7S_CTRL(0x40038EF8 : $val) ==="

print_bit $val 15 "BIT_PBINT_7S_FLAG_CLR"
print_bit $val 14 "BIT_EXT_RSTN_FLAG_CLR"
print_bit $val 13 "BIT_CHGR_INT_FLAG_CLR"
print_bit $val 12 "BIT_PBINT2_FLAG_CLR"
print_bit $val 11 "BIT_PBINT_FLAG_CLR"
#print_bit $val 10 ""
#print_bit $val 9 ""
print_sel_info $val 8 1 "BIT_PBINT_7S_RST_SWMODE" "00:long_reset 01:short_reset"
print_sel_info $val 4 0xF "BITS_PBINT_7S_RST_THRESHOLD" "00:2s 01:2s 02:3s 03:4s 04:5s 05:6s 06:7s 07:8s 08:9s 09:10s 10:11s 11:12s 12:13s 13:14s 14:15s 15:16s"
print_sel_info $val 3 1 "BIT_EXT_RSTN_MODE" "00:EXT_INT 01:Reset"
print_bit $val 2 "BIT_PBINT_7S_AUTO_ON_EN"
print_sel_info $val 0 1 "BIT_PBINT_7S_RST_DISABLE" "00:enable 01:disable"
print_sel_info $val 0 1 "BIT_PBINT_7S_RST_MODE" "00:SW_reset 01:HW_reset"
echo " "

##### ANA_REG_GLB_HWRST_RTC
val=$(read_reg 0x40038C00 0x02FC)
echo "=== ANA_REG_GLB_HWRST_RTC(0x40038EFC : $val) ==="

bin_hex_print_chars $val 8 0xFF "BITS_HWRST_RTC_REG_STS(set_by_HWRST_RTC_SET)="
bin_hex_print_chars $val 0 0xFF "BITS_HWRST_RTC_REG_SET="
echo " "

##### ANA_REG_GLB_ARCH_EN
val=$(read_reg 0x40038C00 0x0304)
echo "=== ANA_REG_GLB_ARCH_EN(0x40038F04 : $val) ==="

print_bit $val 0 "BIT_ARCH_EN"
echo " "

##### ANA_REG_GLB_MCU_WR_PROT_VALUE
val=$(read_reg 0x40038C00 0x0308)
echo "=== ANA_REG_GLB_MCU_WR_PROT_VALUE(0x40038F08 : $val) ==="

print_bit $val 15 "BIT_MCU_WR_PROT(when mcu_wr_prot_value==0x3c4d)"
echo " "

##### ANA_REG_GLB_PWR_WR_PROT_VALUE
val=$(read_reg 0x40038C00 0x030c)
echo "=== ANA_REG_GLB_PWR_WR_PROT_VALUE(0x40038F0c : $val) ==="

print_bit $val 15 "BIT_PWR_WR_PROT(when mcu_wr_prot_value==0x6e7f)"
echo " "

##### ANA_REG_GLB_SMPL_CTRL0
val=$(read_reg 0x40038C00 0x0310)
echo "=== ANA_REG_GLB_SMPL_CTRL0(0x40038F10 : $val) ==="

print_sel_info $val 13 0x7 "SMPL_TIMER_THRESHOLD" "00:0.25s 01:0.5s 02:0.75s 03:1s 04:1.25s 05:1.5s 06:1.75s 07:2s"
bin_hex_print_chars $val 0 0x1FFF "SMPL=0x1935?:enable:disable"
echo " "

##### ANA_REG_GLB_SMPL_CTRL1
val=$(read_reg 0x40038C00 0x0314)
echo "=== ANA_REG_GLB_SMPL_CTRL1(0x40038F14 : $val) ==="

print_sel_info $val 13 0x7 "SMPL_TIMER_THRESHOLD" "00:0.25s 01:0.5s 02:0.75s 03:1s 04:1.25s 05:1.5s 06:1.75s 07:2s"
bin_hex_print_chars $val 0 0x1FFF "SMPL=0x1935?:enable:disable"
print_bit $val 11 "BIT_SMPL_PWR_ON_FLAG(set once SMPL timer not expired)"
print_bit $val 0 "BIT_SMPL_MODE_WR_ACK_FLAG(set once SMPL mode not expired)"
print_bit $val 11 "BIT_SMPL_PWR_ON_SET(set once SMPL timer not expired)"
print_bit $val 0 "BIT_SMPL_EN"
echo " "

##### ANA_REG_GLB_RTC_RST0
val=$(read_reg 0x40038C00 0x0318)
echo "=== ANA_REG_GLB_RTC_RST0(0x40038F18 : $val) ==="
echo " "
##### ANA_REG_GLB_RTC_RST1
val=$(read_reg 0x40038C00 0x031c)
echo "=== ANA_REG_GLB_RTC_RST1(0x40038F1c : $val) ==="
echo " "
##### ANA_REG_GLB_RTC_RST2
val=$(read_reg 0x40038C00 0x0320)
echo "=== ANA_REG_GLB_RTC_RST2(0x40038F20 : $val) ==="
echo " "
##### ANA_REG_GLB_BATDET_CUR_CTRL
val=$(read_reg 0x40038C00 0x0324)
echo "=== ANA_REG_GLB_BATDET_CUR_CTRL(0x40038F24 : $val) ==="
echo " "
##### ANA_REG_GLB_RTC_CLK_STOP
val=$(read_reg 0x40038C00 0x0328)
echo "=== ANA_REG_GLB_RTC_CLK_STOP(0x40038F28 : $val) ==="
echo " "
##### ANA_REG_GLB_VBAT_DROP_CNT
val=$(read_reg 0x40038C00 0x032c)
echo "=== ANA_REG_GLB_VBAT_DROP_CNT(0x40038F2c : $val) ==="
bin_hex_print_chars $val 0 0xFFF "BITS_VBAT_DROP_CNT="
echo " "

##### ANA_REG_GLB_SWRST_CTRL0
val=$(read_reg 0x40038C00 0x0330)
echo "=== ANA_REG_GLB_SWRST_CTRL0(0x40038F30 : $val) ==="

print_bit $val 15 "BIT_POR_RTC_PD"
print_bit $val 10 "BIT_EXT_RSTN_PD_EN"
print_bit $val 9 "BIT_PB_7S_RST_PD_EN"
print_sel_info $val 6 1 "BIT_KEY2_7S_RST_EN" "00:2key_reset 01:1key_reset"
print_bit $val 5 "BIT_WDG_RST_PD_EN"
bin_hex_print_chars $val 0 0xF "BITS_SW_RST_PD_THRESHOLD="
echo " "

##### ANA_REG_GLB_SWRST_CTRL1
val=$(read_reg 0x40038C00 0x0334)
echo "=== ANA_REG_GLB_SWRST_CTRL1(0x40038F34 : $val) ==="

print_bit $val 3 "BIT_SW_RST_USB33_PD_EN"
print_bit $val 2 "BIT_SW_RST_EMMCCORE_PD_EN"
print_bit $val 1 "BIT_SW_RST_SDIO_PD_EN"
print_bit $val 0 "BIT_SW_RST_SDCORE_PD_EN"
echo " "

##### ANA_REG_GLB_OSC_CTRL
val=$(read_reg 0x40038C00 0x0338)
echo "=== ANA_REG_GLB_OSC_CTRL(0x40038F38 : $val) ==="
##### ANA_REG_GLB_OTP_CTRL
val=$(read_reg 0x40038C00 0x033c)
echo "=== ANA_REG_GLB_OTP_CTRL(0x40038F3c : $val) ==="
##### ANA_REG_GLB_FREE_TIMER_LOW
val=$(read_reg 0x40038C00 0x0348)
echo "=== ANA_REG_GLB_FREE_TIMER_LOW(0x40038F48 : $val) ==="
##### ANA_REG_GLB_FREE_TIMER_HIGH
val=$(read_reg 0x40038C00 0x034c)
echo "=== ANA_REG_GLB_FREE_TIMER_HIGH(0x40038F4c : $val) ==="
##### ANA_REG_GLB_RC_CTRL_0
val=$(read_reg 0x40038C00 0x0350)
echo "=== ANA_REG_GLB_RC_CTRL_0(0x40038F50 : $val) ==="
##### ANA_REG_GLB_LOW_PWR_CLK32K_CTRL
val=$(read_reg 0x40038C00 0x0354)
echo "=== ANA_REG_GLB_LOW_PWR_CLK32K_CTRL(0x40038F54 : $val) ==="
echo " "


echo "===============================  DCDC ARM SLP CTRL  ================================="
##### ANA_REG_GLB_DCDC_ARM0_SLP_CTRL0
val=$(read_reg 0x40038C00 0x0358)
echo "=== ANA_REG_GLB_DCDC_ARM0_SLP_CTRL0(0x40038F58 : $val) ==="
##### ANA_REG_GLB_DCDC_ARM0_SLP_CTRL1
val=$(read_reg 0x40038C00 0x035C)
echo "=== ANA_REG_GLB_DCDC_ARM0_SLP_CTRL1(0x40038F5C : $val) ==="
##### ANA_REG_GLB_DCDC_ARM0_SLP_CTRL2
val=$(read_reg 0x40038C00 0x0360)
echo "=== ANA_REG_GLB_DCDC_ARM0_SLP_CTRL2(0x40038F60 : $val) ==="
##### ANA_REG_GLB_DCDC_ARM0_SLP_CTRL3
val=$(read_reg 0x40038C00 0x0364)
echo "=== ANA_REG_GLB_DCDC_ARM0_SLP_CTRL3(0x40038F64 : $val) ==="
##### ANA_REG_GLB_DCDC_ARM0_SLP_CTRL4
val=$(read_reg 0x40038C00 0x0368)
echo "=== ANA_REG_GLB_DCDC_ARM0_SLP_CTRL4(0x40038F68 : $val) ==="
##### ANA_REG_GLB_DCDC_ARM0_SLP_CTRL5
val=$(read_reg 0x40038C00 0x036C)
echo "=== ANA_REG_GLB_DCDC_ARM0_SLP_CTRL5(0x40038F6C : $val) ==="
echo " "
##### ANA_REG_GLB_DCDC_ARM1_SLP_CTRL0
val=$(read_reg 0x40038C00 0x0370)
echo "=== ANA_REG_GLB_DCDC_ARM1_SLP_CTRL0(0x40038F70 : $val) ==="
##### ANA_REG_GLB_DCDC_ARM1_SLP_CTRL1
val=$(read_reg 0x40038C00 0x0374)
echo "=== ANA_REG_GLB_DCDC_ARM1_SLP_CTRL1(0x40038F74 : $val) ==="
##### ANA_REG_GLB_DCDC_ARM1_SLP_CTRL2
val=$(read_reg 0x40038C00 0x0378)
echo "=== ANA_REG_GLB_DCDC_ARM1_SLP_CTRL2(0x40038F78 : $val) ==="
##### ANA_REG_GLB_DCDC_ARM1_SLP_CTRL3
val=$(read_reg 0x40038C00 0x037C)
echo "=== ANA_REG_GLB_DCDC_ARM1_SLP_CTRL3(0x40038F7C : $val) ==="
##### ANA_REG_GLB_DCDC_ARM1_SLP_CTRL4
val=$(read_reg 0x40038C00 0x0380)
echo "=== ANA_REG_GLB_DCDC_ARM1_SLP_CTRL4(0x40038F80 : $val) ==="
##### ANA_REG_GLB_DCDC_ARM1_SLP_CTRL5
val=$(read_reg 0x40038C00 0x0384)
echo "=== ANA_REG_GLB_DCDC_ARM1_SLP_CTRL5(0x40038F84 : $val) ==="
echo " "

##### ANA_REG_GLB_SWLPRO_CTRL_0
val=$(read_reg 0x40038C00 0x0388)
echo "=== ANA_REG_GLB_SWLPRO_CTRL_0(0x40038F88 : $val) ==="
##### ANA_REG_GLB_SWLPRO_CTRL_1
val=$(read_reg 0x40038C00 0x038C)
echo "=== ANA_REG_GLB_SWLPRO_CTRL_1(0x40038F8C : $val) ==="
##### ANA_REG_GLB_SWLPRO_CTRL_2
val=$(read_reg 0x40038C00 0x0390)
echo "=== ANA_REG_GLB_SWLPRO_CTRL_2(0x40038F90 : $val) ==="
echo " "

#no_exec
}


echo "===============================  SC2731 DCDC/LDO VALUE  ================================="
########################   print ldo
function hex_1() {
	printf "%08x" $1
}

function ldo_hex() {
	value=$1
	vshift=$2
	vmask=$3
	echo -n $(`expr hex_1` $(($value >> $vshift & $vmask)) | tr a-z A-Z)
}

function print_ldo() {
	ldo_name=$1
	reg_val=$2
	reg_bit=$3
	reg_mask=$4   #$(echo "obase=10; ibase=16; $4"|bc)
	vol_start=$5
	vol_step=$6

	echo -n "$ldo_name : "
	vol=$(ldo_hex $reg_val $reg_bit $reg_mask)
	vol_dec=$(echo "obase=10; ibase=16; $vol"|bc);
	real_vol=$(echo $vol_start+$vol_dec*$vol_step|bc);
	echo $real_vol "mV"
}

function print_ldo_reg() {
	ldo_name=$1
	reg_val=$2
	reg_bit=$3
	reg_mask=$4   #$(echo "obase=10; ibase=16; $4"|bc)
	vol_start=$5
	vol_step=$6

	echo -n "$ldo_name : "
	printf "(0x%08x): " $reg_val
	vol=$(ldo_hex $reg_val $reg_bit $reg_mask)
	vol_dec=$(echo "obase=10; ibase=16; $vol"|bc);
	real_vol=$(echo $vol_start+$vol_dec*$vol_step|bc);
	echo $real_vol "mV"
}

function print_dcdc_reg() {
	ldo_name=$1
	reg_val=$2
	vol_step=$3
	vol_base=$4
	ldo_reg=$5

	echo -n "$ldo_name : "
	printf "(0x%08x): " $ldo_reg
	cal_vol=$(ldo_hex $reg_val 0 0x1f | tr a-z A-Z)
	cal_dec=$(echo "obase=10; ibase=16; $cal_vol"|bc|tr a-z A-Z);
	real_vol=$(echo $vol_base+$cal_dec*$vol_step|bc);
	echo $real_vol "mV"
}

function print_dcdc() {
	ldo_name=$1
	reg_val=$2
	vol_step=$3
	vol_base=$4

	echo -n "$ldo_name : "
	cal_vol=$(ldo_hex $reg_val 0 0x1f | tr a-z A-Z)
	cal_dec=$(echo "obase=10; ibase=16; $cal_vol"|bc|tr a-z A-Z);
	real_vol=$(echo $vol_base+$cal_dec*$vol_step|bc);
	echo $real_vol "mV"
}

function print_dcdc_1() {
	ldo_name=$1
	reg_val=$2

	echo -n "$ldo_name : "

	cal_vol=$(ldo_hex $reg_val 0 0x1f | tr a-z A-Z)
	cal_dec=$(echo "obase=10; ibase=16; $cal_vol"|bc|tr a-z A-Z);

	base_vol=$(ldo_hex $reg_val 5 0x1f | tr a-z A-Z)
	base_dec=$(echo "obase=10; ibase=16; $base_vol"|bc|tr a-z A-Z);

	real_vol=$(echo $base_dec*100+600+$cal_dec*"100/32"|bc);
	echo $real_vol "mV"
}

###  DCDC_ARM0_VOL
val=$(read_reg 0x40038C00 0x54)
base_v=$((($val >> 5 & 0x1F)*100+400))
print_dcdc_reg "DCDC_ARM0_VOL" $val "100/32" $base_v $val

###  ANA_REG_GLB_DCDC_ARM1_VOL
val=$(read_reg 0x40038C00 0x64)
base_v=$((($val >> 5 & 0x1F)*100+400))
print_dcdc_reg "DCDC_ARM1_VOL" $val "100/32" $base_v $val

###  ANA_REG_GLB_DCDC_CORE_VOL
val=$(read_reg 0x40038C00 0x74)
base_v=$((($val >> 5 & 0x1F)*100+400))
print_dcdc_reg "DCDC_CORE_VOL" $val "100/32" $base_v $val

###  ANA_REG_GLB_DCDC_GPU_VOL
val=$(read_reg 0x40038C00 0x84)
base_v=$((($val >> 5 & 0x1F)*100+400))
print_dcdc_reg "DCDC_GPU_VOL" $val "100/32" $base_v $val

###  ANA_REG_GLB_DCDC_MEM_VOL
val=$(read_reg 0x40038C00 0x98)
base_v=$((($val >> 5 & 0x1F)*100+600))
print_dcdc_reg "DCDC_MEM_VOL" $val "100/32" $base_v $val

###  ANA_REG_GLB_DCDC_GEN_VOL
val=$(read_reg 0x40038C00 0xA8)
base_v=$((($val >> 5 & 0x1F)*100+600))
print_dcdc_reg "DCDC_GEN_VOL" $val "100/32" $base_v $val

###  ANA_REG_GLB_DCDC_RF_VOL
val=$(read_reg 0x40038C00 0xB8)
base_v=$((($val >> 5 & 0x1F)*100+600))
print_dcdc_reg "DCDC_RF_VOL" $val "100/32" $base_v $val

###  ANA_REG_GLB_DCDC_WPA_VOL
val=$(read_reg 0x40038C00 0xD8)
base_v=$((($val >> 5 & 0x1F)*100+600))
print_dcdc_reg "DCDC_WPA_VOL" $val "100/32" $base_v $val

### ANA_REG_GLB_LDO_CAMA0_REG1
val=$(read_reg 0x40038C00 0x0100)
print_ldo_reg "LDO_CAMA0" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_CAMA1_REG1
val=$(read_reg 0x40038C00 0x0108)
print_ldo_reg "LDO_CAMA1" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_CAMMOT_REG1
val=$(read_reg 0x40038C00 0x0110)
print_ldo_reg "LDO_CAMMOT" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_SIM0_REG1
val=$(read_reg 0x40038C00 0x0118)
print_ldo_reg "LDO_SIM0" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_SIM1_REG1
val=$(read_reg 0x40038C00 0x0120)
print_ldo_reg "LDO_SIM1" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_VLDO_REG1
val=$(read_reg 0x40038C00 0x0128)
print_ldo_reg "LDO_VLDO" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_EMMCCORE_REG1
val=$(read_reg 0x40038C00 0x0130)
print_ldo_reg "LDO_EMMCCORE" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_SD_REG1
val=$(read_reg 0x40038C00 0x0138)
print_ldo_reg "LDO_SDCORE" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_SDIO_REG1
val=$(read_reg 0x40038C00 0x0140)
print_ldo_reg "LDO_SDIO" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_VDD28_REG1
val=$(read_reg 0x40038C00 0x0148)
print_ldo_reg "LDO_VDD28" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_WIFIPA_REG1
val=$(read_reg 0x40038C00 0x0150)
print_ldo_reg "LDO_WIFIPA" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_DCXO_REG1
val=$(read_reg 0x40038C00 0x0158)
print_ldo_reg "LDO_DCXO" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_USB33_REG1
val=$(read_reg 0x40038C00 0x0160)
print_ldo_reg "LDO_USB33" $val 0 0xff 1200 10

### ANA_REG_GLB_LDO_CAMD0_REG1
val=$(read_reg 0x40038C00 0x0180)
print_ldo_reg "LDO_CAMD0" $val 0 0x7f 1150 "6.25"

### ANA_REG_GLB_LDO_CAMD1_REG1
val=$(read_reg 0x40038C00 0x0188)
print_ldo_reg "LDO_CAMD1" $val 0 0x7f 1150 "6.25"

### ANA_REG_GLB_LDO_CON_REG1
val=$(read_reg 0x40038C00 0x0190)
print_ldo_reg "LDO_CON" $val 0 0x7f 1150 "6.25"

### ANA_REG_GLB_LDO_CAMIO_REG1
val=$(read_reg 0x40038C00 0x0198)
print_ldo_reg "LDO_CAMIO" $val 0 0x7f 1150 "6.25"

### ANA_REG_GLB_LDO_AVDD18_REG1
val=$(read_reg 0x40038C00 0x01A0)
print_ldo_reg "LDO_AVDD18" $val 0 0x7f 1150 "6.25"

### ANA_REG_GLB_LDO_VDDRF_REG1
val=$(read_reg 0x40038C00 0x01A8)
print_ldo_reg "LDO_VDDRF" $val 0 0x7f 1150 "6.25"

### ANA_REG_GLB_LDO_VDDSRAM_REG1
val=$(read_reg 0x40038C00 0x01B0)
print_ldo_reg "LDO_VDDSRAM" $val 0 0x1f 1150 "6.25"

### ANA_REG_GLB_KPLED_CTRL
val=$(read_reg 0x40038C00 0x02C4)
print_ldo_reg "KPLED_CTRL" $val 0 0xff 1200 10

### ANA_REG_GLB_VIBR_CTRL0
val=$(read_reg 0x40038C00 0x02C8)
print_ldo_reg "VIBR_CTRL0" $val 0 0xff 1200 10

