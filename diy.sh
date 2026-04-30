#!/bin/bash
#============================================================================
# OpenWrt 配置脚本 - 修改本地的 config/xg-040g-md.config
# 用法: ./diy.sh
#============================================================================

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 配置文件路径（根据你的实际位置调整）
CONFIG_FILE="config/xg-040g-md.config"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo ">>> 修改配置文件: $CONFIG_FILE"

# 备份原配置
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# 1. 配置 ip-full（禁用 BusyBox ip）
sed -i '/^CONFIG_PACKAGE_ip-full=/d' "$CONFIG_FILE"
sed -i '/^CONFIG_BUSYBOX_CONFIG_IP/d' "$CONFIG_FILE"
cat >> "$CONFIG_FILE" << "EOF"
CONFIG_PACKAGE_ip-full=y
CONFIG_BUSYBOX_CONFIG_IP=n
CONFIG_BUSYBOX_CONFIG_IPADDR=n
CONFIG_BUSYBOX_CONFIG_IPLINK=n
CONFIG_BUSYBOX_CONFIG_IPROUTE=n
CONFIG_BUSYBOX_CONFIG_IPTUNNEL=n
CONFIG_BUSYBOX_CONFIG_IPRULE=n
EOF

# 2. 添加软件包
for pkg in \
    "luci-app-easytier" "luci-i18n-easytier-zh-cn" \
    "luci-app-ksmbd" "luci-i18n-ksmbd-zh-cn" \
    "luci-app-diskman" "luci-i18n-diskman-zh-cn" \
    "luci-app-hd-idle" "luci-i18n-hd-idle-zh-cn" \
    "luci-app-ttyd" "luci-i18n-ttyd-zh-cn" \
    "luci-app-aria2" "luci-i18n-aria2-zh-cn" \
    "luci-theme-argon" "luci-app-argon-config"; do
    sed -i "/^CONFIG_PACKAGE_${pkg}=/d" "$CONFIG_FILE"
    echo "CONFIG_PACKAGE_${pkg}=y" >> "$CONFIG_FILE"
done

# 3. 设置默认中文和 Argon 主题
sed -i '/^CONFIG_LUCI_LANG_/d' "$CONFIG_FILE"
sed -i '/^CONFIG_LUCI_THEME_DEFAULT=/d' "$CONFIG_FILE"
cat >> "$CONFIG_FILE" << "EOF"
CONFIG_LUCI_LANG_zh-cn=y
CONFIG_LUCI_THEME_DEFAULT=argon
EOF

echo "✅ 配置文件已修改: $CONFIG_FILE"