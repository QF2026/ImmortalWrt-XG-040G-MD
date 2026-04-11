# ImmortalWrt for XG-040G-MD

ImmortalWrt firmware for NOKIA BELL XG-040G-MD

编译脚本基于 [OpenWrt-for-XG-040G-MD](https://github.com/dalutou/OpenWrt-for-XG-040G-MD) 修改。

* 固件使用 ImmortalWrt openwrt-25.12 分支构建。
* 仅包含流量监控插件luci-app-nlbwmon
* 使用 [tcboot.bin](https://pan.baidu.com/s/1UWUXmZro0XFKmP-UHnbc1A?pwd=Nwrt#list/path=%2FNwrt%E5%9B%BA%E4%BB%B6%2F%E5%85%89%E7%8C%AB%E8%B4%9D%E5%B0%94) 作为引导程序。
* **请准备好 USB-TTL，做好随时救砖的准备**。

## 目前遇到的问题

XG-040G-MD 使用的 NAND Flash 主要有两个型号：
* SkyHigh S35ML02G300
* Fudan Micro FM25G02B: 晚期生产的，用此型号的较多。

> 目前的 patch 虽然可以让系统正常运行，但是稳定性没有得到验证，大家请谨慎刷机使用。
