#!/bin/bash
#============================================================================
# OpenWrt 定制化配置脚本 (apk包管理器环境)
# 功能: 集成 luci-app-easytier, FileManager 及内核模块依赖
# 用法: ./diy.sh
#============================================================================

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# >>> 请根据你的实际配置文件路径修改 <<<
CONFIG_FILE="config/xg-040g-md.config"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo ">>> 开始修改配置文件: $CONFIG_FILE"

# 备份原配置
if [ ! -f "$CONFIG_FILE.bak" ]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
    echo "✅ 已备份原配置为 $CONFIG_FILE.bak"
fi

#============================================================
# Part 1: 克隆第三方软件包源码
#============================================================
echo ""
echo ">>> 克隆第三方软件源码..."

# 1.2 克隆 luci-app-easytier
cd "$OPENWRT_PATH"
if [ ! -d "package/luci-app-easytier" ]; then
    echo "克隆 luci-app-easytier ..."
    git clone --depth 1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier
    echo "✅ luci-app-easytier 克隆完成"
else
    echo "⚠️ package/luci-app-easytier 目录已存在，跳过克隆"
fi

#更改默认IP
sed -i 's/192.168.1.1/192.168.1.200/g' package/base-files/files/bin/config_generate

#============================================================
# Part 2: 添加 kmod-tun 支持（VPN 和组网工具的虚拟网卡驱动）
#============================================================
cd "$SCRIPT_DIR"
echo ""
echo ">>> 添加 kmod-tun 支持..."
sed -i '/^CONFIG_PACKAGE_kmod-tun=/d' "$CONFIG_FILE"
echo "CONFIG_PACKAGE_kmod-tun=y" >> "$CONFIG_FILE"

#============================================================
# Part 3: 开启透明代理功能所需的内核模块
#============================================================
echo ""
echo ">>> 添加透明代理 (TPROXY) 所需内核模块..."
for mod in kmod-nft-socket kmod-nft-tproxy kmod-inet-diag kmod-netlink-diag; do
    sed -i "/^CONFIG_PACKAGE_${mod}=/d" "$CONFIG_FILE"
    echo "CONFIG_PACKAGE_${mod}=y" >> "$CONFIG_FILE"
done

# 同时开启必要的内核网络选项以配合 nftables 使用透明代理
echo ">>> 开启内核 nftables 透明代理支持..."
for opt in CONFIG_NETFILTER_XT_MATCH_SOCKET=y CONFIG_NETFILTER_XT_TARGET_TPROXY=y CONFIG_NF_TPROXY_IPV4=y CONFIG_NF_TPROXY_IPV6=y CONFIG_INET_DIAG=y CONFIG_INET_TCP_DIAG=y CONFIG_NETLINK_DIAG=y; do
    opt_name="${opt%=*}"
    sed -i "/^${opt_name}=/d" "$CONFIG_FILE"
    echo "$opt" >> "$CONFIG_FILE"
done

#============================================================
# Part 4: 添加基础库支持（可能被特定应用需要的运行时库）
#============================================================
echo ""
echo ">>> 添加基础库支持..."
for lib in libatomic libncurses-dev; do
    sed -i "/^CONFIG_PACKAGE_${lib}=/d" "$CONFIG_FILE"
    echo "CONFIG_PACKAGE_${lib}=y" >> "$CONFIG_FILE"
done

#============================================================
# Part 5: 添加常用软件列表
#============================================================
echo ""
echo ">>> 添加应用软件包..."
for pkg in \
    "luci-app-easytier" "luci-i18n-easytier-zh-cn" \
    "luci-app-filemanager" "luci-i18n-filemanager-zh-cn" \
    "luci-app-ksmbd" "luci-i18n-ksmbd-zh-cn" \
    "luci-app-diskman" "luci-i18n-diskman-zh-cn" \
    "luci-app-hd-idle" "luci-i18n-hd-idle-zh-cn" \
    "luci-app-ttyd" "luci-i18n-ttyd-zh-cn" \
    "luci-app-aria2" "luci-i18n-aria2-zh-cn" \
    "luci-app-rtp2httpd" "rtp2httpd" \
    "luci-theme-argon" "luci-app-argon-config"; do
    var_name="CONFIG_PACKAGE_${pkg}"
    sed -i "/^${var_name}=/d" "$CONFIG_FILE"
    echo "${var_name}=y" >> "$CONFIG_FILE"
done

#============================================================
# Part 6: 设置系统默认语言和主题
#============================================================
echo ""
echo ">>> 设置默认语言（简体中文）和 Argon 主题..."
sed -i '/^CONFIG_LUCI_LANG_/d' "$CONFIG_FILE"
sed -i '/^CONFIG_LUCI_THEME_DEFAULT=/d' "$CONFIG_FILE"
cat >> "$CONFIG_FILE" << EOF
CONFIG_LUCI_LANG_zh-cn=y
CONFIG_LUCI_THEME_DEFAULT=argon
EOF

echo ""
echo "✅ 固件配置定制完成！"
echo "================================================"
