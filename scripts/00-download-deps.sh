#!/bin/bash
# =============================================================================
# 准备构建依赖
# -----------------------------------------------------------------------------
# 内核 image / headers / firmware / alsa deb：从 kernel-deb 的 release 下载预编译包
# Venus VAAPI 驱动源码：从上游获取源码素材
#
# 使用方式：
#   bash scripts/00-download-deps.sh <内核版本> [内核 deb 仓库]
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

# ---------- 1) 内核 image/headers：下载预编译 deb（几分钟完成，不再从源码编译） ----------
KERNEL_RELEASE="https://github.com/$REPO/releases/download/kernel-v${KERNEL_VERSION}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 下载预编译内核 deb ..."
curl -fsSL -o "$DEBS_DIR/linux-image-xiaomi-raphael.deb" \
    "$KERNEL_RELEASE/linux-image-xiaomi-raphael.deb"
curl -fsSL -o "$DEBS_DIR/linux-headers-xiaomi-raphael.deb" \
    "$KERNEL_RELEASE/linux-headers-xiaomi-raphael.deb"

# ---------- 2) firmware / alsa deb（二进制固件与 UCM 配置） ----------
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 获取 firmware / alsa deb ..."
curl -fsSL -o "$DEBS_DIR/firmware-xiaomi-raphael.deb" \
    "$KERNEL_RELEASE/firmware-xiaomi-raphael.deb"
curl -fsSL -o "$DEBS_DIR/alsa-xiaomi-raphael.deb" \
    "$KERNEL_RELEASE/alsa-xiaomi-raphael.deb"

# ---------- 3) hexagonrpcd + libhexagonrpc（SDSP 传感器守护进程，从 plucky backport） ----------
# hexagonrpcd 在 noble 官方源中不存在，但从 Ubuntu plucky 源 backport 的两个 arm64 deb
# 仅依赖 adduser/libc6，noble 完全满足，可安全安装。
HEX_BASE="http://ports.ubuntu.com/ubuntu-ports/pool/universe/h/hexagonrpc"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ backport hexagonrpcd (来自 plucky) ..."
curl -fsSL -o "$DEBS_DIR/libhexagonrpc0.3_0.3.2-1_arm64.deb" \
    "$HEX_BASE/libhexagonrpc0.3_0.3.2-1_arm64.deb"
curl -fsSL -o "$DEBS_DIR/hexagonrpcd_0.3.2-1_arm64.deb" \
    "$HEX_BASE/hexagonrpcd_0.3.2-1_arm64.deb"
# 校验 sha256，确保 deb 完整且与 plucky 官方索引一致
echo "c27d54320f09c6484e5d38574c22551dd7b2f060a25f03204f4f5f50210d2b10  $DEBS_DIR/libhexagonrpc0.3_0.3.2-1_arm64.deb" | sha256sum -c - >/dev/null
echo "d98d2e3bf4d1e005caffe5a2e3259f67f7a4cabaad7ca77aebe8b52170b47b56  $DEBS_DIR/hexagonrpcd_0.3.2-1_arm64.deb" | sha256sum -c - >/dev/null

# ---------- 4) Venus VAAPI 驱动源码（构建期内编译安装） ----------
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 下载 Venus VAAPI 驱动源码 ..."
curl -fsSL -o "$DEBS_DIR/venus-vaapi-driver.tar.gz" \
    "https://github.com/snowf14k3/venus-vaapi-driver/archive/refs/heads/main.tar.gz"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ 依赖准备完成:"
ls -lh "$DEBS_DIR"
