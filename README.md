# 项目说明
- 该项目是基于immortalwrt-master进行的定制
- - 适配机型：WXY-OEC/OECT



# 功能特性
| 内置插件                 | 状态 | 内置插件         | 状态 | 内置插件         | 状态 | 
|:------------------------:|:----:|:----------------:|:----:|:----------------:|:----:|
| store                | ✅   | lucky                       | ✅   | docker              | ✅   |
| passwall             | ✅ 


## WXY-OES 定制内容
- 添加 SATA 硬盘指示灯控制脚本
功能：仅在检测到硬盘插入时，SATA 指示灯才会亮起，避免无硬盘时的无效亮灯。

```shell
# 脚本路径
/usr/sbin/oes_sata_leds.sh
```
- 首次开机时，脚本配置不会立即生效，需重启系统后，SATA 指示灯控制功能才会正常工作。
```shell
# 手动执行命令
bash /usr/sbin/oes_sata_leds.sh
```
- 如需恢复原版功能，可执行以下命令：
```shell
# 删除监控脚本
sudo rm /usr/sbin/oes_sata_leds.sh

# 从rc.local中移除启动项
sudo sed -i '/oes_sata_leds.sh/d' /etc/rc.local

# 重启系统
reboot
```

