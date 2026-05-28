#!/bin/bash

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 请根据你的实际配置文件路径修改
CONFIG_FILE="config/xg-040g-md.config"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi
# 备份原配置
if [ ! -f "$CONFIG_FILE.bak" ]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
    echo "✅ 已备份原配置为 $CONFIG_FILE.bak"
fi

# 克隆 luci-app-easytier
cd "$OPENWRT_PATH"
rm -rf package/luci-app-easytier
    git clone --depth 1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier
    echo "luci-app-easytier 克隆完成"

# 更新feeds,以备需要
  ./scripts/feeds update -a
  ./scripts/feeds install -a

# 更改默认IP
sed -i 's/192.168.1.1/192.168.1.200/g' package/base-files/files/bin/config_generate

# 添加升级固件支持(test)
mkdir -p files/lib/upgrade/
cp -af ../patch-25.12/target/linux/airoha/an7581/base-files/lib/upgrade/platform.sh files/lib/upgrade/platform.sh
chmod +x files/lib/upgrade/platform.sh

cd "$SCRIPT_DIR"
sed -i '/CONFIG_PACKAGE_kmod-tun/d' "$CONFIG_FILE"
echo "CONFIG_PACKAGE_kmod-tun=y" >> "$CONFIG_FILE"

#echo ">>> 添加透明代理 (TPROXY) 所需内核模块..."
#for mod in kmod-nft-socket kmod-nft-tproxy kmod-inet-diag kmod-netlink-diag; do
#    sed -i "/CONFIG_PACKAGE_${mod}/d" "$CONFIG_FILE"
#    echo "CONFIG_PACKAGE_${mod}=y" >> "$CONFIG_FILE"
#done

#echo ">>> 添加基础库及有关支持..."
#for lib in libatomic libncurses-dev openssl-util rpcd-mod-rpcsys; do
#    sed -i "/CONFIG_PACKAGE_${lib}/d" "$CONFIG_FILE"
#    echo "CONFIG_PACKAGE_${lib}=y" >> "$CONFIG_FILE"
#done

# 添加常用软件列表
for pkg in \
    "luci-app-easytier" "luci-i18n-easytier-zh-cn" \
    "easytier-noweb" \
    "luci-app-filemanager" "luci-i18n-filemanager-zh-cn" \
    "luci-app-ksmbd" "luci-i18n-ksmbd-zh-cn" \
    "luci-app-hd-idle" "luci-i18n-hd-idle-zh-cn" \
    "luci-app-ttyd" "luci-i18n-ttyd-zh-cn" \
    "luci-app-aria2" "luci-i18n-aria2-zh-cn" \
    "luci-app-rtp2httpd" "rtp2httpd" \
    "unzip" \
    "luci-theme-argon" "luci-app-argon-config"; do
    var_name="CONFIG_PACKAGE_${pkg}"
    sed -i "/${var_name}/d" "$CONFIG_FILE"
    echo "${var_name}=y" >> "$CONFIG_FILE"
done


