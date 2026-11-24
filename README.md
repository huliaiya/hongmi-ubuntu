<div align="center">

# <img src="https://img.shields.io/badge/Device-huliboot-FF6900?style=for-the-badge&logo=android&logoColor=white" alt="Device"/> <img src="https://img.shields.io/badge/Linux-Ubuntu_24.04-E95420?style=for-the-badge&logo=linux&logoColor=white" alt="Linux"/>

# 📱 huliboot Ubuntu 24.04 构建项目

### huliboot · 预编译内核 + U-Boot · 一键产出 GNOME 桌面系统镜像

[![Build](https://img.shields.io/github/actions/workflow/status/huliaiya/hongmi-ubuntu/build-system.yml?style=flat-square&label=Build&logo=github-actions&logoColor=white)](https://github.com/huliaiya/hongmi-ubuntu/actions)
[![Release](https://img.shields.io/github/v/release/huliaiya/hongmi-ubuntu?style=flat-square&label=Release&logo=github&logoColor=white)](https://github.com/huliaiya/hongmi-ubuntu/releases)
[![Stars](https://img.shields.io/github/stars/huliaiya/hongmi-ubuntu?style=flat-square&logo=github&logoColor=white)](https://github.com/huliaiya/hongmi-ubuntu/stargazers)

---

</div>

## ✨ 项目简介

本项目为 **huliboot（基于 Redmi K20 Pro / 小米 9T Pro，代号 Raphael，SM8150）** 专属的 **Ubuntu 24.04 LTS（noble）** 系统镜像构建方案，默认产出 **GNOME 桌面版**。系统品牌名、主机名、USB 设备名均已统一为 `huliboot`。

本项目采用**经过验证的预编译内核 deb 与 U-Boot 固件**：内核来自 [`GengWei1997/kernel-deb`](https://github.com/GengWei1997/kernel-deb) 的 release，U-Boot 来自 [`GengWei1997/linux-xiaomi-raphael-uboot`](https://github.com/GengWei1997/linux-xiaomi-raphael-uboot) 的 release，无需在本地耗时编译内核与引导程序。系统打包全部交由 **GitHub Actions 工作流**完成，点一下即可产出可刷机镜像。

> **默认配置**：仅构建 `ubuntu-gnome` + `noble`（Ubuntu 24.04 LTS），内核版本 `7.3`。

## 🎯 构建特性

| 项目 | 说明 |
|:---|:---|
| 🐧 **内核** | 采用 [`GengWei1997/kernel-deb`](https://github.com/GengWei1997/kernel-deb) 预编译 deb（image / headers / firmware / alsa），内置 Raphael 内核与 Venus 硬解支持 |
| 🔧 **U-Boot** | 采用 [`GengWei1997/linux-xiaomi-raphael-uboot`](https://github.com/GengWei1997/linux-xiaomi-raphael-uboot) release 的预编译固件（`u-boot.img`），脚本 `scripts/build-uboot.sh` 负责获取 |
| 🖥️ **系统** | Ubuntu 24.04 LTS (noble) + GNOME 桌面 |
| 🧩 **固件** | 高通 firmware、ALSA UCM 配置随镜像集成 |
| 🤖 **自动化** | GitHub Actions 一键触发，产物自动发布到 Releases |

## 🖥️ 设备硬件适配

| 分类 | 支持项目 | 状态 |
|:---:|:---|:---:|
| 🌐 **网络** | 2.4G / 5G 双频 Wi-Fi | ✅ |
| 📡 **蓝牙** | 文件传输 · 音频输出 | ✅ |
| 📶 **蜂窝** | 网络支持 | ✅ |
| 🔌 **USB** | NCM 网络共享 · OTG 功能 | ✅ |
| 🖥️ **显示** | 屏幕输出 · GPU 渲染 | ✅ |
| 🔊 **音频** | 扬声器 · 耳机输出 | ✅ |
| 🎬 **视频** | Venus VA-API 硬件解码/编码 (H.264/HEVC) | ✅ |
| 👆 **输入** | 触摸屏 · 闪光灯（手电筒） | ✅ |
| 🔋 **系统** | 电池检测 · 实时时钟 · FDE 加密 | ✅ |

## 🚀 快速上手

### 方式一：下载预构建镜像（推荐）

前往 [Releases](https://github.com/huliaiya/hongmi-ubuntu/releases) 下载最新镜像（`rootfs-ubuntu-gnome-*.7z`），解压后按下方[刷机教程](#-刷机教程installation)刷机，无需本地编译。

> ⚠️ GNOME 桌面镜像体积可能超过 2GB，超出部分请前往项目 [Actions → Artifacts](https://github.com/huliaiya/hongmi-ubuntu/actions) 下载。

### 方式二：GitHub Actions 自定义构建

1. **Fork** 本仓库至个人 GitHub 账号
2. 进入 **Actions** → 选择「构建系统镜像」工作流 → 点击 **Run workflow**
3. 默认参数即为 `ubuntu-gnome` + `noble` + 内核 `7.3`，按需调整后运行
4. 工作流会下载**预编译内核 deb 与 U-Boot 固件**，全程在 GitHub Actions 完成系统打包，无需本地编译
5. 构建完成后镜像与 U-Boot 固件自动发布至 Releases

### 方式三：本地构建

```bash
# 安装依赖（Debian/Ubuntu）
sudo apt update
sudo apt install -y mmdebstrap ubuntu-keyring p7zip-full build-essential \
  bc flex bison ccache clang lld llvm libssl-dev libelf-dev libdw-dev \
  debhelper rsync kmod cpio

# 一键构建（下载预编译内核 deb 与 U-Boot 固件 + 打包系统镜像）
sudo env SYSTEM_TYPE=ubuntu-gnome UBUNTU_VERSION=noble KERNEL_VERSION=7.3 \
  BOOTSTRAP_TOOL=mmdebstrap bash build.sh ubuntu-gnome 7.3
```

## 📲 刷机教程（Installation）

刷机步骤与上游 [U-Boot Wiki 的 Installation 页面](https://github.com/GengWei1997/linux-xiaomi-raphael-uboot/wiki/Installation) 一致，整理如下，方便在仓库首页直接查看。

### 前置条件

- ✅ 设备已完成 **Bootloader 解锁**
- ✅ 电脑已安装 `adb` / `fastboot` 工具
- ✅ 下载镜像压缩包并解压，得到：
  - `rootfs.img` — 系统镜像（内部为 GPT 分区：`Boot` 启动分区含 systemd-boot 引导 + `Root` 根分区）
  - `u-boot.img` — U-Boot 引导固件（来自 [U-Boot release v1.0.0](https://github.com/GengWei1997/linux-xiaomi-raphael-uboot/releases/tag/v1.0.0)，或本项目 Releases 附带）

### 刷机命令

```bash
# 1. 进入 Fastboot 模式
adb reboot bootloader

# 2. 擦除分区
fastboot erase dtbo
fastboot erase boot
fastboot erase userdata

# 3. 刷入镜像（内核与 initramfs 已包含在 rootfs.img 的 Boot 分区中）
fastboot flash boot u-boot.img
fastboot flash userdata rootfs.img

# 4. 重启设备
fastboot reboot
```

> 💡 镜像采用 GPT 分区表（Boot ESP + Root ext4），分区细节见下方[分区方案](#-分区方案gpt)。
>
> ⚠️ 刷机前请备份重要数据；U-Boot 属于底层引导固件，刷写有变砖风险，请确认设备状态后再操作。

## 🔧 脚本与目录结构

```
build.sh                       # 主构建入口（依次调用 01~18）
config/
  build-config.sh              # 系统类型/版本映射 + GPT 分区参数
  raphael.config               # 内核配置片段（保留备用）
scripts/
  build-kernel.sh              # 内核版本工具（默认构建流程不调用）
  build-uboot.sh               # ★ 获取预编译 U-Boot 固件
  00-download-deps.sh          # ★ 下载预编译内核 deb / firmware / alsa / hexagonrpcd
  01-create-image.sh           # 创建镜像与 GPT 分区
  02-bootstrap.sh              # 安装 Ubuntu 基础系统
  03~18                        # 网络/源/软件包/语言/内核/用户/电源/音频/收尾
.github/workflows/build-system.yml  # 自动化构建与发布
```

## 📦 镜像特性

### 🌐 全版本通用

- 默认配置 **清华软件源**
- 预装简体中文语言包 + 中国标准时区，开箱汉化
- 支持 USB NCM 网络共享，电脑直连设备 SSH
- 内置 SSH 服务，支持 root / 普通用户远程登录
- 支持 `dpkg -i` 直接更新内核（固定名引导自动刷新，自动卸载旧内核）

| 账户 | 用户名 | 密码 |
|:---:|:---:|:---:|
| 普通用户 | `huliboot` | `1234` |
| 超级用户 | `root` | `1234` |

> 📌 USB NCM 连接时，设备 IP：`172.16.42.1`，SSH 连接：`ssh huliboot@172.16.42.1`
>
> 🌐 系统默认 DNS 为阿里云公共 DNS（`223.5.5.5` / `223.6.6.6`），构建时写入 `/etc/resolv.conf`。

### 🖥️ GNOME 桌面版

- GNOME 桌面环境，适配桌面使用场景
- 开机 15 秒自动熄屏，降低设备功耗
- 自定义快捷命令：`leijun` 关闭屏幕 · `jinfan` 点亮屏幕

## 🔄 内核更新

镜像已集成 **固定名引导**（与 [Nura](https://wiki.nura.eco) / postmarketOS 一致）：`dpkg -i ./*.deb` 即可自动更新内核，钩子自动刷新 `/boot/vmlinuz` + `/boot/initrd.img` 与 dtbs。

如需单独获取 U-Boot 固件：

```bash
bash scripts/build-uboot.sh
# 产物见 uboot-out/u-boot-sm8150-xiaomi-raphael.zip，解压后为 u-boot.img
```

> ⚠️ U-Boot 属于底层引导固件，刷写有变砖风险。高通平台是否需要额外签名/打包为 ABL 取决于设备与 bootloader 状态，请自行确认后再刷写。

## 💽 分区方案（GPT）

镜像采用 **GPT 分区表**（与 [Nura](https://wiki.nura.eco) / postmarketOS 一致），整体通过 `fastboot flash userdata rootfs.img` 刷入设备，内核与根文件系统都位于镜像内部，无需改动设备的 Android 分区布局。

| 分区 | 编号 | 文件系统 | 标签 | 大小 | 类型 |
|:---:|:---:|:---|:---:|:---:|:---|
| Boot | p1 | FAT32 | `Boot` | 256M | ESP (`c12a7328-f81f-11d2-ba4b-00a0c93ec93b`) |
| Root | p2 | ext4 | `Root` | 剩余空间 | DPS arm64 root (`b921b045-1df0-41c3-af44-4c6f280d3fae`) |

- 逻辑扇区大小: **4096 字节**（匹配 UFS 存储）
- 根分区固定 UUID: `ee8d3593-59b1-480e-a3b6-4fefb17ee7d8`
- 启动链: u-boot → systemd-boot（`EFI/BOOT/BOOTAA64.EFI`）→ 固定引导条目 → 内核

## 🙏 致谢

本项目站在以下开源项目与开发者的肩膀上（排名不分先后）：

- [GengWei1997/linux](https://github.com/GengWei1997/linux) — SM8150 Raphael 内核源码
- [GengWei1997/kernel-deb](https://github.com/GengWei1997/kernel-deb) — 预编译内核 deb、配置与固件素材
- [GengWei1997/linux-xiaomi-raphael-uboot](https://github.com/GengWei1997/linux-xiaomi-raphael-uboot) — 预编译 U-Boot 固件与刷机教程
- [snowf14k3/venus-vaapi-driver](https://github.com/snowf14k3/venus-vaapi-driver) — Venus 硬解驱动
- Nura（原 postmarketOS）、Linux 内核团队、Debian / Ubuntu 社区、Phosh 团队及所有开源贡献者

---

<div align="center">

**如果这个项目对你有帮助，请给一个 ⭐ Star 支持一下！**

</div>
