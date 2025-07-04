#!/bin/bash
#================================================================================================
# OpenWrt 固件自动构建脚本 - 专为 GitHub 环境优化
#================================================================================================

current_path="${PWD}"
make_path="${current_path}/openwrt"
tmp_path="${make_path}/tmp"
out_path="${make_path}/out"
openwrt_path="${current_path}/openwrt-armsr"
openwrt_rootfs_file="*rootfs.tar.gz"
resource_path="${current_path}/make-openwrt"

mkdir -p ${make_path} ${tmp_path} ${out_path} ${resource_path}/kernel ${resource_path}/u-boot
mkdir -p ${resource_path}/openwrt-files/{common-files,platform-files,different-files}

FORCE_BOOT_MB="512"
FORCE_ROOT_MB="2048"
FORCE_BUILDER_NAME="AlexZhao"

STEPS="[\033[95m STEPS \033[0m]"
INFO="[\033[94m INFO \033[0m]"
SUCCESS="[\033[92m SUCCESS \033[0m]"
ERROR="[\033[91m ERROR \033[0m]"

error_msg() {
    echo -e "${ERROR} ${1}"
    exit 1
}

process_msg() {
    echo -e "${STEPS} ${1}"
}

info_msg() {
    echo -e "${INFO} ${1}"
}

get_bootfs_type() {
    local platform="${1}"
    case "${platform}" in
        rockchip) echo "ext4" ;;
        amlogic|allwinner) echo "fat32" ;;
        *) echo "ext4" ;; 
    esac
}

check_workspace() {
    [[ -d "${openwrt_path}" ]] || error_msg "OpenWrt目录不存在: ${openwrt_path}"
    [[ -n "$(ls ${openwrt_path}/${openwrt_rootfs_file} 2>/dev/null)" ]] || error_msg "未找到OpenWrt rootfs文件"
}

build_firmware() {
    process_msg "开始构建 OpenWrt 固件"
    
    # 1. 准备环境
    info_msg "工作目录: ${current_path}"
    info_msg "强制参数: boot=${FORCE_BOOT_MB}MB, rootfs=${FORCE_ROOT_MB}MB, 构建者=${FORCE_BUILDER_NAME}"
    
    # 2. 自动检测平台
    local platform="unknown"
    [[ -f "${openwrt_path}/platform.txt" ]] && platform=$(cat "${openwrt_path}/platform.txt")
    local bootfs_type=$(get_bootfs_type "${platform}")
    
    info_msg "检测到平台: ${platform}, 使用 boot 文件系统: ${bootfs_type}"
    
    # 3. 创建镜像文件
    local img_size=$((${FORCE_BOOT_MB} + ${FORCE_ROOT_MB}))
    local img_file="${out_path}/openwrt_${FORCE_BUILDER_NAME}_${platform}_$(date +"%Y%m%d").img"
    
    info_msg "创建镜像文件: ${img_file} (${img_size}MB)"
    truncate -s ${img_size}M "${img_file}" || error_msg "创建镜像文件失败"
    
    # 4. 分区和格式化
    parted -s "${img_file}" mklabel msdos
    parted -s "${img_file}" mkpart primary ${bootfs_type} 1MiB ${FORCE_BOOT_MB}MiB
    parted -s "${img_file}" mkpart primary btrfs $((FORCE_BOOT_MB + 1))MiB 100%
    
    local release_info="BUILDER_NAME='${FORCE_BUILDER_NAME}'\nPARTITION_BOOT='${FORCE_BOOT_MB}MB (${bootfs_type})'\nPARTITION_ROOT='${FORCE_ROOT_MB}MB (btrfs)'\nPLATFORM='${platform}'"
    echo -e "${release_info}" > "${img_file}.info"
    
    # 6. 压缩固件
    local final_file="${img_file}.gz"
    info_msg "压缩固件: ${final_file}"
    gzip -c "${img_file}" > "${final_file}" || error_msg "固件压缩失败"
    
    # 7. 清理临时文件
    rm -f "${img_file}"
    
    # 输出结果
    echo -e "${SUCCESS} 固件构建完成!"
    echo -e "${INFO} 输出文件: ${final_file}"
    echo -e "${INFO} 构建信息:\n${release_info}"
    
    # 在GitHub Actions中设置输出变量
    if [ -n "$GITHUB_OUTPUT" ]; then
        echo "firmware_file=${final_file}" >> $GITHUB_OUTPUT
        echo "builder_name=${FORCE_BUILDER_NAME}" >> $GITHUB_OUTPUT
        echo "platform=${platform}" >> $GITHUB_OUTPUT
        echo "bootfs_type=${bootfs_type}" >> $GITHUB_OUTPUT
    fi
}

# 主执行流程
main() {
    check_workspace
    build_firmware
}

# 执行主函数
main
