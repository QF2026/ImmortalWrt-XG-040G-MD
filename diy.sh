#!/bin/bash
#
# ImmortalWrt 云编译
#

cd $GITHUB_WORKSPACE/immortalwrt || exit 1

#=====================================================================
# 1. 官方源：EasyTier、rtp2httpd
#=====================================================================
git clone --depth 1 https://github.com/EasyTier/EasyTier.git package/EasyTier
git clone --depth 1 https://github.com/stackia/rtp2httpd.git package/rtp2httpd

#=====================================================================
# 2. 拉取 argon-config
#=====================================================================
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

#=====================================================================
# 更新 feeds 并安装
#=====================================================================
./scripts/feeds update -a
./scripts/feeds install -a

#=====================================================================
# 3. 修改管理IP：192.168.1.200
#=====================================================================
sed -i 's/192.168.1.1/192.168.1.200/g' package/base-files/files/bin/config_generate

#=====================================================================
# 4. 禁用 busybox ip，改用 ip-full
#=====================================================================
sed -i 's/CONFIG_BUSYBOX_DEFAULT_IP=y/CONFIG_BUSYBOX_DEFAULT_IP=n/g' .config
echo "CONFIG_PACKAGE_ip-full=y" >> .config

#=====================================================================
# 5. 安装所有软件 + 中文包（argon 来自官方源）
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
echo "CONFIG_PACKAGE_$pkg=y" >> .config
done

#=====================================================================
# 6. 默认中文 + 默认 Argon 主题
#=====================================================================
sed -i 's/CONFIG_LUCI_LANG_.*/CONFIG_LUCI_LANG_zh_cn=y/' .config
echo "CONFIG_LUCI_THEME_DEFAULT=argon" >> .config

#=====================================================================
echo "
==================================================
✅ 官方源编译完成
✅ 管理IP：192.168.1.200
✅ argon主题：来自 ImmortalWrt 官方 luci feed
✅ argon-config：jerrykuku 仓库（官方无）
✅ 已装：ksmbd diskman hd-idle ttyd easytier rtp2httpd aria2 argon
==================================================
"
