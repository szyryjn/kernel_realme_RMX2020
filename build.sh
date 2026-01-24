#!/bin/bash

BUILD_FOR="A16"
DATE="$(TZ=Asia/India date +%Y%m%d)"
KERNEL_NAME="KSU-NEXT-${BUILD_FOR}-${DATE}.zip"

function compile() 
{
rm -rf AnyKernel
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
export ARCH=arm64
export KBUILD_BUILD_HOST=wildmoon
export KBUILD_BUILD_USER="szyryjn"
if [ ! -d "clang" ]; then
    git clone https://gitlab.com/moehacker/clang-r498229b clang --depth=1
fi

[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 RMX2020_defconfig

PATH="${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      CC="clang" \
                      LLVM=1 \
                      CONFIG_NO_ERROR_ON_MISMATCH=y \
                      2>&1 | tee build.log
}

function zipping()
{
git clone --depth=1 https://github.com/szyryjn/AnyKernel3.git AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
(zip -r9 "$KERNEL_NAME" *)
}

compile
zipping
