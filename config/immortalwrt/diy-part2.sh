#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='immortalwrt-$(date +%Y%m%d)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By Only'/g" package/base-files/files/etc/openwrt_release


# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#

# 修改luci-app-store版本号
grep -q '^[[:space:]]*PKG_VERSION:=' feeds/kenzo/luci-app-store/Makefile && [[ $(grep '^[[:space:]]*PKG_VERSION:=' feeds/kenzo/luci-app-store/Makefile | cut -d= -f2-) == *-* ]] && sed -i -e "s/^\([[:space:]]*PKG_VERSION:=\).*/\1$(grep '^[[:space:]]*PKG_VERSION:=' feeds/kenzo/luci-app-store/Makefile | cut -d= -f2- | cut -d- -f1)/" -e "/^[[:space:]]*#/b; /^[[:space:]]*PKG_RELEASE:=/c\PKG_RELEASE:=$(grep '^[[:space:]]*PKG_VERSION:=' feeds/kenzo/luci-app-store/Makefile | cut -d= -f2- | cut -d- -f2-)" feeds/kenzo/luci-app-store/Makefile

# 修改首页samba4快速设置路径问题
# sed -i 's|/cgi-bin/luci/admin/services/samba4|/cgi-bin/luci/admin/nas/samba4|g' feeds/kenzo/luci-app-quickstart/htdocs/luci-static/quickstart/index.js

#
# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------
