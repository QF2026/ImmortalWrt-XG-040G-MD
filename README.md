# ImmortalWrt for XG-040G-MD

ImmortalWrt firmware for NOKIA BELL XG-040G-MD

编译脚本基于 [dalutou/OpenWrt-for-XG-040G-MD](https://github.com/dalutou/OpenWrt-for-XG-040G-MD) 修改。

* 固件使用 ImmortalWrt openwrt-25.12 分支构建。
* 仅包含流量监控插件luci-app-nlbwmon
* 基于[xiangtailiang/openwrt](https://github.com/xiangtailiang/openwrt)仓库的补丁适配SkyHigh S35ML02G300和Fudan Micro FM25G02B闪存
* 基于[XG-040G-MD (AN7581) NPU 固件加载报错分析与修复记录](https://github.com/xiangtailiang/OpenWrt-for-XG-040G-MD/blob/main/docs/npu-firmware-load.md)修复内核日志报错：
  ```text
  airoha-npu 1e900000.npu: Direct firmware load for airoha/en7581_npu_rv32.bin failed with error -2
  ```
* [获取超级密码](https://www.right.com.cn/FORUM/thread-8440823-1-1.html)
* [拆机、刷机、配置、原厂分区备份 教程](https://www.right.com.cn/forum/thread-8467912-1-1.html)
* 使用[Nwrt](https://nwrt.kuroneko.host/flashdocs/XG-040G-MD.html)提供的 [tcboot.bin](https://pan.baidu.com/s/1UWUXmZro0XFKmP-UHnbc1A?pwd=Nwrt#list/path=%2FNwrt%E5%9B%BA%E4%BB%B6%2F%E5%85%89%E7%8C%AB%E8%B4%9D%E5%B0%94) 作为引导程序。
* **请准备好 USB-TTL，做好随时救砖的准备**。
