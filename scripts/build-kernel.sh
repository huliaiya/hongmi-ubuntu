#!/bin/bash
# =============================================================================
# 从源码编译 Xiaomi Raphael (SM8150) 内核 deb 包
# -----------------------------------------------------------------------------
# 产物（统一重命名为本构建流程约定的固定名）：
#   linux-image-xiaomi-raphael.deb
#   linux-headers-xiaomi-raphael.deb
#
# 使用方式：
#   bash scripts/build-kernel.sh <内核版本> [输出目录]
# 例：
#   bash scripts/build-kernel.sh 7.3
#
# 依赖（见 workflow "编译内核与固件" 步骤）：
#   build-essential bc flex bison ccache clang-23 libssl-dev libelf-dev
#   debhelper dpkg-dev rsync kmod cpio
# =============================================================================
set -e

KERNEL_VERSION="${1:-7.3}"
OUT_DIR="${2:-xiaomi-raphael-debs_${KERNEL_VERSION}}"

# 内核源码仓库与分支（上游 GengWei1997/linux 的分支命名形如 raphael-v7.3.0）
# 把用户传入的版本（如 7.3 / v7.3 / 7.3.0 / raphael-v7.3.0）规范化为 raphael-vX.Y.Z
normalize_kernel_branch() {
    local v="$1"
    # 去掉可能的 raphael- 前缀
    v="${v#raphael-}"
    # 补前导 v
    [[ "$v" == v* ]] || v="v${v}"
    # 补 .0 使成为三段式（v7.3 -> v7.3.0）
    local num="${v#v}"
    case "$num" in
        *.*.*) ;;                 # 已是 x.y.z
        *.*)   v="${v}.0" ;;      # x.y -> x.y.0
        *)     v="${v}.0.0" ;;    # x -> x.0.0
    esac
    echo "raphael-${v}"
}

KERNEL_REPO="${KERNEL_REPO:-GengWei1997/linux}"
KERNEL_BRANCH="${KERNEL_BRANCH:-$(normalize_kernel_branch "$KERNEL_VERSION")}"

# 本仓库内的内核配置片段
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KERNEL_CONFIG="${KERNEL_CONFIG:-$ROOT_DIR/config/raphael.config}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 🧠 从源码编译内核"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 版本:   ${KERNEL_VERSION}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 源码:   ${KERNEL_REPO} @ ${KERNEL_BRANCH}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 配置:   ${KERNEL_CONFIG}"
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 输出:   ${OUT_DIR}"

if [ ! -f "$KERNEL_CONFIG" ]; then
    echo "错误: 内核配置文件不存在: $KERNEL_CONFIG" >&2
    exit 1
fi

# 编译工具链：默认用系统 clang (LLVM=1)；若设置 CLANG_VERSION 则锁定版本。
# ccache 存在时用其包裹 clang 以加速重复编译。
CLANG_VER="${CLANG_VERSION:-}"
kmake() {
    local llvm="LLVM=1"
    if [ -n "$CLANG_VER" ]; then
        llvm="LLVM=-${CLANG_VER}"
        if command -v ccache >/dev/null 2>&1; then
            make -j"$(nproc)" ARCH=arm64 "$llvm" \
                CC="ccache clang-${CLANG_VER}" \
                HOSTCC="ccache clang-${CLANG_VER}" "$@"
        else
            make -j"$(nproc)" ARCH=arm64 "$llvm" "$@"
        fi
    else
        if command -v ccache >/dev/null 2>&1; then
            make -j"$(nproc)" ARCH=arm64 "$llvm" \
                CC="ccache clang" HOSTCC="ccache clang" "$@"
        else
            make -j"$(nproc)" ARCH=arm64 "$llvm" "$@"
        fi
    fi
}

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 克隆内核源码 ..."
git clone --depth 1 --branch "$KERNEL_BRANCH" \
    "https://github.com/${KERNEL_REPO}.git" "$WORKDIR/linux"

cd "$WORKDIR/linux"

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 应用内核配置 (raphael.config) ..."
cp "$KERNEL_CONFIG" arch/arm64/configs/raphael.config
kmake defconfig raphael.config

echo "[$(date +'%Y-%m-%d %H:%M:%S')]   └─ 编译内核与模块 (make deb-pkg) ..."
kmake deb-pkg

cd "$WORKDIR"
mkdir -p "$OUT_DIR"

IMAGE_DEB=$(ls -1 linux-image-*.deb 2>/dev/null | grep -v '\-dbg_' | head -n1 || true)
HEADERS_DEB=$(ls -1 linux-headers-*.deb 2>/dev/null | head -n1 || true)

if [ -z "$IMAGE_DEB" ]; then
    echo "错误: 未生成 linux-image deb" >&2
    exit 1
fi
if [ -z "$HEADERS_DEB" ]; then
    echo "错误: 未生成 linux-headers deb" >&2
    exit 1
fi

mv "$IMAGE_DEB"  "$OUT_DIR/linux-image-xiaomi-raphael.deb"
mv "$HEADERS_DEB" "$OUT_DIR/linux-headers-xiaomi-raphael.deb"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ 内核编译完成:"
ls -lh "$OUT_DIR"
