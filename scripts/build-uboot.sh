#!/bin/bash
# =============================================================================
# 获取 Xiaomi Raphael (SM8150) U-Boot 预编译固件
# -----------------------------------------------------------------------------
# U-Boot 由上游开发者使用私有补丁编译（公开源码 Aospa-raphael-unofficial/u-boot
# 并不包含 raphael/sm8150 设备支持，无法从源码编出可用固件），因此本脚本改为
# 直接下载上游 release 中经过验证的预编译固件。
#
# 固件来源：GengWei1997/linux-xiaomi-raphael-uboot  release v1.0.0
# 默认版本：u-boot-sm8150-xiaomi-raphael-20260911.zip（日期最新）
#
# 产物：uboot-out/u-boot-sm8150-xiaomi-raphael.zip
#       （统一命名，供 workflow 后续校验/上传/发布步骤使用）
#
# 使用方式：
#   bash scripts/build-uboot.sh
#
# 可用环境变量覆盖：
#   UBOOT_REPO     固件所在仓库（默认 GengWei1997/linux-xiaomi-raphael-uboot）
#   UBOOT_TAG      release 标签（默认 v1.0.0）
#   UBOOT_ASSET    固件文件名（默认 u-boot-sm8150-xiaomi-raphael-20260911.zip）
#   OUT_DIR        产物目录（默认 uboot-out）
#
# 备注：高通平台 U-Boot 刷写存在变砖风险，请确认设备状态后再操作。
# =============================================================================
set -e

UBOOT_REPO="${UBOOT_REPO:-GengWei1997/linux-xiaomi-raphael-uboot}"
UBOOT_TAG="${UBOOT_TAG:-v1.0.0}"
UBOOT_ASSET="${UBOOT_ASSET:-u-boot-sm8150-xiaomi-raphael-20260911.zip}"
OUT_DIR="${OUT_DIR:-uboot-out}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 🔧 获取预编译 U-Boot 固件"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 来源: ${UBOOT_REPO} @ ${UBOOT_TAG}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 固件: ${UBOOT_ASSET}"

DL_URL="https://github.com/${UBOOT_REPO}/releases/download/${UBOOT_TAG}/${UBOOT_ASSET}"
DEST_DIR="${ROOT_DIR}/${OUT_DIR}"
mkdir -p "$DEST_DIR"

TMP_ZIP=$(mktemp)
trap 'rm -f "$TMP_ZIP"' EXIT

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 下载中 ..."
curl -fsSL --retry 3 --retry-delay 2 -o "$TMP_ZIP" "$DL_URL"

# 基本完整性检查：非空且是 zip
[ -s "$TMP_ZIP" ] || { echo "错误: 下载的固件为空" >&2; exit 1; }
if command -v unzip >/dev/null 2>&1; then
    unzip -tq "$TMP_ZIP" >/dev/null 2>&1 || { echo "错误: 固件 zip 损坏" >&2; exit 1; }
fi

# 统一命名为 workflow 约定的文件名
cp -f "$TMP_ZIP" "${DEST_DIR}/u-boot-sm8150-xiaomi-raphael.zip"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ U-Boot 固件就绪:"
ls -lh "${DEST_DIR}/u-boot-sm8150-xiaomi-raphael.zip"
