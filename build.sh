#!/bin/bash

# Set kernel name
BUILD_FOR="-A15"
DATE="$(TZ=Asia/India date +%Y%m%d)"
KERNEL_NAME="KSU-NEXT${BUILD_FOR}-${DATE}.zip"

# Add KernelSU-Next in Kernel Source
if [ ! -d "KernelSU-NEXT" ]; then curl -LSs "https://raw.githubusercontent.com/szyryjn/KSUN-SZYRYJN/next/kernel/setup.sh" | bash -s next; fi

function compile() 
{
rm -rf AnyKernel
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
export ARCH=arm64
export KBUILD_BUILD_HOST=WildMoon
export KBUILD_BUILD_USER="szyryjn"
if [ ! -d "clang" ]; then
    wget https://android.googlesource.com/platform//prebuilts/clang/host/linux-x86/+archive/1ab7c4ac121885e76bb58ba77e5cef8aca3c2881/clang-r498229b.tar.gz -O "aosp-clang.tar.gz"
    mkdir clang && tar -xf aosp-clang.tar.gz -C clang && rm -rf aosp-clang.tar.gz
fi

[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 RMX2020_defconfig

PATH="${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      CC="clang" \
                      LLVM=1 \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
}

function zipping()
{
rm -rf AnyKernel
git clone -b RMX2020-KSUN --depth=1 https://github.com/szyryjn/AnyKernel3.git AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
(zip -r9 "$KERNEL_NAME" *)
}

compile
zipping
