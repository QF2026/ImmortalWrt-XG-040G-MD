#!/bin/bash
#========================================================================
# OpenWrt 固件配置自定义脚本
# 功能：添加 EasyTier、修改 IP、增加软件包、禁用 BusyBox ip、设置中文/主题
# 用法：放在 OpenWrt 源码根目录，在 make defconfig 前执行
#========================================================================

set -e  # 出错即停

# 进入脚本所在目录（即 OpenWrt 源码根目录）
cd "$(dirname "$0")" || exit 1

echo ">>> [1/6] 添加 EasyTier 的 LuCI feed..."
if ! grep -q "easytier" feeds.conf.default; then
    echo "src-git easytier https://github.com/EasyTier/luci-app-easytier.git" >> feeds.conf.default
fi

echo ">>> [2/6] 更新并安装 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

echo ">>> [3/6] 修改管理 IP 为 192.168.1.200..."
sed -i 's/192.168.1.1/192.168.1.200/g' package/base-files/files/bin/config_generate

# 配置文件路径（根据你的设备修改，或用通用 .config）
CONFIG_FILE=".config"   # 如果使用设备配置模板，改为 config/设备名.config

echo ">>> [4/6] 配置软件包及 BusyBox ip 禁用..."

# 4.1 清理可能存在的冲突项（防止重复）
sed -i '/^CONFIG_PACKAGE_ip-full=/d' "$CONFIG_FILE"
sed -i '/^CONFIG_BUSYBOX_CONFIG_IP/d' "$CONFIG_FILE"

# 4.2 启用 ip-full 并禁用 BusyBox 的 ip 组件
cat >> "$CONFIG_FILE" << "EOF"
CONFIG_PACKAGE_ip-full=y
CONFIG_BUSYBOX_CONFIG_IP=n
CONFIG_BUSYBOX_CONFIG_IPADDR=n
CONFIG_BUSYBOX_CONFIG_IPLINK=n
CONFIG_BUSYBOX_CONFIG_IPROUTE=n
CONFIG_BUSYBOX_CONFIG_IPTUNNEL=n
CONFIG_BUSYBOX_CONFIG_IPRULE=n
EOF

# 4.3 添加其他软件包及中文包
cat >> "$CONFIG_FILE" << "EOF"
CONFIG_PACKAGE_luci-app-easytier=y
CONFIG_PACKAGE_luci-i18n-easytier-zh-cn=y
CONFIG_PACKAGE_luci-app-ksmbd=y
CONFIG_PACKAGE_luci-i18n-ksmbd-zh-cn=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_luci-app-hd-idle=y
CONFIG_PACKAGE_luci-i18n-hd-idle-zh-cn=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y
CONFIG_PACKAGE_luci-app-aria2=y
CONFIG_PACKAGE_luci-i18n-aria2-zh-cn=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
EOF

echo ">>> [5/6] 设置默认语言为中文，默认主题为 Argon..."
# 5.1 语言
sed -i '/^CONFIG_LUCI_LANG_/d' "$CONFIG_FILE"
echo "CONFIG_LUCI_LANG_zh-cn=y" >> "$CONFIG_FILE"

# 5.2 主题（Argon）
sed -i '/^CONFIG_LUCI_THEME_DEFAULT=/d' "$CONFIG_FILE"
echo "CONFIG_LUCI_THEME_DEFAULT=argon" >> "$CONFIG_FILE"

echo ">>> [6/6] 完成！后续请运行 make defconfig 和 make 进行编译"
echo ""
echo "=================================================="
echo "✅ 已修改内容："
echo "   - 管理 IP：192.168.1.200"
echo "   - 禁用 BusyBox ip，启用 ip-full"
echo "   - 添加 EasyTier、ksmbd、diskman、ttyd、aria2、argon 等"
echo "   - 默认语言：中文；默认主题：Argon"
echo "=================================================="