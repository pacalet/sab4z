#!/usr/bin/env bash

version=0.1
packages=/packages/LabSoC
downloads=/opt/downloads
builds=/opt/builds
toolchain=arm-unknown-linux-gnueabihf
sab4z=$(realpath $(dirname $(realpath $0))/..)


usage="
usage: $( basename $0 ) [options] BOARD

OPTIONS (default)
	-s, --sab4z SAB4Z ($sab4z)
		Path of SAB4Z clone

	-p, --packages PACKAGES ($packages)
		Path of directory in which buildroot, linux-xlnx, u-boot-xlnx and device-tree-xlnx clones are to be found

	-d, --downloads DOWNLOADS ($downloads)
		Path of directory where to download packages

	-b, --builds BUILDS ($builds)
		Path of directory where to build things

	-t, --toolchain TOOLCHAIN ($toolchain)
		Prefix of toolchain (whithout trailing -)

	-h, --help
		Display help text and exit

	-v, --version
		Display version and exit

BOARD
	zybo, zed and zc706 are the only currently supported boards
"

TEMP=$( getopt --options s:p:d:b:t:hv \
	--longoptions sab4z:,packages:,downloads:,builds:,toolchain:,help,version \
	--name $0 -- "$@" )

if [ $? != 0 ]; then
	echo "*** Invalid arguments" >&2
	echo "$usage" >&2
	exit 1
fi

eval set -- "$TEMP"

while true ; do
	case "$1" in
		-s|--sab4z) sab4z=$2; shift 2;;
		-p|--packages) packages=$2; shift 2;;
		-d|--downloads) downloads=$2; shift 2;;
		-b|--builds) builds=$2; shift 2;;
		-t|--toolchain) toolchain=$2; shift 2;;
		-h|--help) echo "$usage"; exit 0;;
		-v|--version) echo "$version"; exit 0;;
		--) shift; break;;
		*) echo "*** Invalid option"; exit 1;;
	esac
done

if [[ $# -ne 1 ]]; then
	echo "*** No board specified" >&2
	echo "$usage" >&2
	exit 1
fi
board="$1"
if [[ "$board" != "zybo" && "$board" != "zed" && "$board" != "zc706" ]]; then
	echo "*** Unknown board" >&2
	echo "$usage" >&2
	exit 1
fi

toolchainpath=$(which ${toolchain}-gcc)
if [[ $? -ne 0 ]]; then
	echo "*** Toolchain $toolchain not found" >&2
	echo "$usage" >&2
	exit 1
fi
toolchainpath=$(dirname $(realpath $toolchainpath))

if [ -d $builds/$board ]; then
	echo "*** Build directory $builds/$board already exists. Exiting..." >&2
	exit 0
fi

echo "sab4z         = $sab4z"
echo "packages      = $packages"
echo "downloads     = $downloads"
echo "builds        = $builds"
echo "toolchain     = $toolchain"
echo "toolchainpath = $toolchainpath"
echo "board         = $board"

toolchainpath=$(dirname $toolchainpath)
buildroot=$packages/buildroot
linux=$packages/linux-xlnx
uboot=$packages/u-boot-xlnx
dts=$packages/device-tree-xlnx

# Bistream
v=$builds/$board/vv
echo "Generating bitstream ($builds/$board/vv/top.runs/impl_1/top_wrapper.bit)..."
mkdir -p $v
make -C $sab4z VVBUILD=$v VVBOARD=$board vv-all

# Device tree
d=$builds/$board/dts
echo "Generating device tree sources ($d/)..."
make -C $sab4z VVBUILD=$v XDTS=$dts DTSBUILD=$d dts
echo "Compiling device tree blob ($builds/$board/sdcard/devicetree.dtb)..."
mkdir -p $builds/$board/sdcard
dtc -I dts -O dtb -o $builds/$board/sdcard/devicetree.dtb $d/system.dts

# FSBL
f=$builds/$board/fsbl
echo "Generating FSBL sources ($f/)..."
mkdir -p $f
make -C $sab4z VVBUILD=$v FSBLBUILD=$f fsbl
echo "Compiling FSBL ($f/executable.elf)..."
make -C $f

# Root filesystem
b=$builds/$board/rootfs
echo "Building root filesystem ($b/images/rootfs.cpio.uboot)..."
mkdir -p $b
touch $b/external.mk $b/Config.in
echo 'name: sab4z' > $b/external.desc
echo 'desc: sab4z system with buildroot' >> $b/external.desc
mkdir -p $b/configs $b/overlays
cp $sab4z/scripts/buildroot_defconfig $b/configs
echo "BR2_DL_DIR=\"$downloads/buildroot-src\"" >> $b/configs/buildroot_defconfig
echo "BR2_TOOLCHAIN_EXTERNAL_PATH=\"$toolchainpath\"" >> $b/configs/buildroot_defconfig
echo "BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX=\"$toolchain\"" >> $b/configs/buildroot_defconfig
echo "BR2_CCACHE_DIR=\"$builds/buildroot-ccache\"" >> $b/configs/buildroot_defconfig
echo "CONFIG_RX=y" > $b/configs/busybox_defconfig
path=$PATH
export PATH=/usr/bin:/bin:$toolchainpath
make -C $buildroot BR2_EXTERNAL=$b O=$b buildroot_defconfig
make -C $b
export PATH=$path

export PATH=$PATH:$b/host/usr/bin
export CROSS_COMPILE=${toolchain}-

# Linux kernel and modules
k=$builds/$board/kernel
echo "Building Linux kernel ($k/arch/arm/boot/uImage)..."
mkdir -p $k
make -C $linux O=$k ARCH=arm xilinx_zynq_defconfig
make -C $k -j24 ARCH=arm
make -C $k ARCH=arm LOADADDR=0x8000 uImage
echo "Copying Linux kernel ($builds/$board/sdcard/uImage)..."
cp $k/arch/arm/boot/uImage $builds/$board/sdcard
echo "Building and installing Linux kernel modules ($b/overlays)..."
make -C $k -j24 ARCH=arm modules
make -C $k ARCH=arm modules_install INSTALL_MOD_PATH=$b/overlays
path=$PATH
export PATH=/usr/bin:/bin:$toolchainpath
make -C $b
export PATH=$path
echo "Copying root filesystem ($builds/$board/sdcard/uramdisk.image.gz)..."
cp $builds/$board/rootfs/images/rootfs.cpio.uboot $builds/$board/sdcard/uramdisk.image.gz

# U-Boot
u=$builds/$board/uboot
echo "Building U-Boot ($u/u-boot.elf)..."
mkdir -p $u
make -C $uboot O=$u zynq_${board}_defconfig
make -C $u -j24
cp $u/u-boot $u/u-boot.elf

# Boot image
echo "Generating boot image ($builds/$board/sdcard/boot.bin)..."
cd $builds/$board
bootgen -w -image $sab4z/scripts/boot.bif -o $builds/$board/sdcard/boot.bin
