#!/bin/bash
#
#

# 自动进入源码目录（100% 安全）
cd "$(dirname "$0")" || exit 1

#=====================================================================
# 拉取官方插件
#=====================================================================
# EasyTier：core + luci-app（完整全套）
git clone --depth 1 https://github.com/EasyTier/EasyTier.git package/EasyTier
git clone --depth 1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# rtp2httpd（官方正确仓库：stackia）
git clone --depth 1 https://github.com/stackia/rtp2httpd.git package/rtp2httpd

# Argon 配置插件（官方源已有主题，只需config）
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

#=====================================================================
# 更新 feeds
#=====================================================================
./scripts/feeds update -a
./scripts/feeds install -a

#=====================================================================
# 1. 修改管理IP：192.168.1.200
#=====================================================================
sed -i 's/192.168.1.1/192.168.1.200/g' package/base-files/files/bin/config_generate

#=====================================================================
# 2. 禁用 busybox ip，安装 ip-full
# 写入路径：config/XG-040G-MD.config
#=====================================================================
sed -i 's/CONFIG_BUSYBOX_DEFAULT_IP=y/CONFIG_BUSYBOX_DEFAULT_IP=n/g' config/XG-040G-MD.config
echo "CONFIG_PACKAGE_ip-full=y" >> config/XG-040G-MD.config

#=====================================================================
# 3. 所有软件包 + 中文包
# 写入路径：config/XG-040G-MD.config
#=====================================================================
ADD_PACKAGES="
luci-app-ksmbd
luci-i18n-ksmbd-zh-cn
luci-app-diskman
luci-i18n-diskman-zh-cn
luci-app-hd-idle
luci-i18n-hd-idle-zh-cn
luci-app-ttyd
luci-i18n-ttyd-zh-cn
luci-app-easytier
luci-i18n-easytier-zh-cn
luci-app-rtp2httpd
luci-i18n-rtp2httpd-zh-cn
luci-app-aria2
luci-i18n-aria2-zh-cn
luci-theme-argon
luci-app-argon-config
"

for pkg in $ADD_PACKAGES; do
echo "CONFIG_PACKAGE_${pkg}=y" >> config/XG-040G-MD.config
done

#=====================================================================
# 4. 默认中文 + 默认 Argon 主题
#=====================================================================
sed -i 's/CONFIG_LUCI_LANG_.*/CONFIG_LUCI_LANG_zh_cn=y/' config/XG-040G-MD.config
echo "CONFIG_LUCI_THEME_DEFAULT=argon" >> config/XG-040G-MD.config

#=====================================================================
echo "
==================================================
✅ 配置文件写入：config/XG-040G-MD.config
✅ 后台IP：192.168.1.200
✅ 已包含全套：easytier-core + luci-app + 中文
✅ 已包含：ksmbd diskman 硬盘休眠 ttyd rtp2httpd aria2 argon
✅ 禁用busybox-ip，安装ip-full
==================================================
"
