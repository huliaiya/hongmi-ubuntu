#!/bin/bash
# =============================================================================
# 从源码编译 Xiaomi Raphael (SM8150) U-Boot
# -----------------------------------------------------------------------------
# 源码上游：Aospa-raphael-unofficial/u-boot（主线 U-Boot 的 raphael/SM8150 支持分支）
# 产物：u-boot-sm8150-xiaomi-raphael.img（ELF，可尝试 fastboot flash abl_a/abl_b）
#       并打包为 u-boot-sm8150-xiaomi-raphael.zip
#
# 使用方式：
#   bash scripts/build-uboot.sh
#
# 可用环境变量覆盖：
#   UBOOT_REPO       源码仓库（默认 Aospa-raphael-unofficial/u-boot）
#   UBOOT_BRANCH     分支（默认 main）
#   UBOOT_DEFCONFIG  defconfig（默认 qcom_defconfig）
#   UBOOT_DT         设备树（默认 qcom/sm8150-xiaomi-raphael；编译期经 fragment 覆盖）
#   CLANG_VERSION    锁定 clang 版本（默认用系统 clang，LLVM=1）
#   OUT_DIR          产物目录（默认 uboot-out）
#
# 备注：高通平台的 U-Boot 是否可直接刷写、需不需要额外签名/打包成 ABL，
#       取决于机型/bootloader 状态；本脚本产出标准编译产物 u-boot.elf。
# =============================================================================
set -e

UBOOT_REPO="${UBOOT_REPO:-Aospa-raphael-unofficial/u-boot}"
UBOOT_BRANCH="${UBOOT_BRANCH:-main}"
UBOOT_DEFCONFIG="${UBOOT_DEFCONFIG:-qcom_defconfig}"
UBOOT_DT="${UBOOT_DT:-qcom/sm8150-xiaomi-raphael}"
CLANG_VER="${CLANG_VERSION:-}"
OUT_DIR="${OUT_DIR:-uboot-out}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 🔧 从源码编译 U-Boot"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 源码: ${UBOOT_REPO} @ ${UBOOT_BRANCH}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 配置: ${UBOOT_DEFCONFIG}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 设备树: ${UBOOT_DT}"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 克隆 U-Boot 源码 ..."
git clone --depth 1 --branch "$UBOOT_BRANCH" \
    "https://github.com/${UBOOT_REPO}.git" "$WORKDIR/u-boot"

cd "$WORKDIR/u-boot"

# 通用 make 封装：ARCH=arm64 + LLVM 工具链，可选 ccache 与 clang 版本
UBMAKE() {
    local llvm="LLVM=1"
    [ -n "$CLANG_VER" ] && llvm="LLVM=-${CLANG_VER}"
    make -j"$(nproc)" ARCH=arm64 "$llvm" "$@"
}

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 生成配置 (${UBOOT_DEFCONFIG}) ..."
UBMAKE O=build "$UBOOT_DEFCONFIG"

# 覆盖默认设备树为 raphael（如上游 defconfig 默认非 raphael）
if command -v scripts/config >/dev/null 2>&1; then
    scripts/config --file build/.config --set-str DEFAULT_DEVICE_TREE "$UBOOT_DT"
    # raphael 需要 LPA/XHCI 等；关闭不必要的调试
    scripts/config --file build/.config --disable TOOLS_ONLY
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 编译 U-Boot ..."
UBMAKE O=build olddefconfig
UBMAKE O=build

# 定位 ELF 产物（不同版本可能叫 u-boot 或 u-boot.elf）
UBIN=""
for c in build/u-boot.elf build/u-boot; do
    [ -f "$c" ] && UBIN="$c" && break
done
if [ -z "$UBIN" ]; then
    echo "错误: 未找到 U-Boot 编译产物 (build/u-boot.elf 或 build/u-boot)" >&2
    exit 1
fi

cd "$WORKDIR"
mkdir -p "$ROOT_DIR/$OUT_DIR"
IMG="$ROOT_DIR/$OUT_DIR/u-boot-sm8150-xiaomi-raphael.img"
cp "$UBIN" "$IMG"

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 打包 zip ..."
( cd "$ROOT_DIR/$OUT_DIR" && 7z a -tzip u-boot-sm8150-xiaomi-raphael.zip u-boot-sm8150-xiaomi-raphael.img >/dev/null )

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ U-Boot 编译完成:"
ls -lh "$ROOT_DIR/$OUT_DIR"
