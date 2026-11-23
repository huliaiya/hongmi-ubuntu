#!/bin/bash
# =============================================================================
# 准备构建依赖
# -----------------------------------------------------------------------------
# 内核 image / headers：由本仓库 scripts/build-kernel.sh 从源码现场编译（不再下载）
# firmware / alsa deb、Venus VAAPI 驱动源码：从上游获取二进制/源码素材
#
# 使用方式：
#   bash scripts/00-download-deps.sh <内核版本> [内核包仓库(仅取 firmware/alsa)]
# =============================================================================
set -e

KERNEL_VERSION="${1:-7.3}"
REPO="${2:-GengWei1997/kernel-deb}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEBS_DIR="xiaomi-raphael-debs_${KERNEL_VERSION}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 📦 准备构建依赖"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 内核版本: ${KERNEL_VERSION}"
mkdir -p "$DEBS_DIR"

# ---------- 1) 内核 image/headers：本仓库从源码编译 ----------
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 从源码编译内核 (build-kernel.sh) ..."
bash "$SCRIPT_DIR/build-kernel.sh" "$KERNEL_VERSION" "$DEBS_DIR"

# ---------- 2) firmware / alsa deb（二进制固件与 UCM 配置，非编译产物） ----------
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 获取 firmware / alsa deb ..."
curl -fsSL -o "$DEBS_DIR/firmware-xiaomi-raphael.deb" \
    "https://github.com/$REPO/releases/download/kernel-v${KERNEL_VERSION}/firmware-xiaomi-raphael.deb"
curl -fsSL -o "$DEBS_DIR/alsa-xiaomi-raphael.deb" \
    "https://github.com/$REPO/releases/download/kernel-v${KERNEL_VERSION}/alsa-xiaomi-raphael.deb"

# ---------- 3) Venus VAAPI 驱动源码（构建期内编译安装） ----------
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 下载 Venus VAAPI 驱动源码 ..."
curl -fsSL -o "$DEBS_DIR/venus-vaapi-driver.tar.gz" \
    "https://github.com/snowf14k3/venus-vaapi-driver/archive/refs/heads/main.tar.gz"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ 依赖准备完成:"
ls -lh "$DEBS_DIR"
