#!/bin/ash

# --- 配置区 ---
# 硬盘LED映射表：ATA ID到LED文件路径的映射关系
declare -A DISK_LED_MAP=(
    ["ata1"]="/sys/class/leds/green:disk/brightness"
    ["ata2"]="/sys/class/leds/green:disk_1/brightness"
    ["ata3"]="/sys/class/leds/green:disk_2/brightness"
)

# --- 核心函数 ---
# 设置LED亮度，带错误处理
set_led_brightness() {
    local led_path="$1" brightness="$2"
    [ -f "$led_path" -a -w "$led_path" ] || { echo "警告: LED文件 [$led_path] 不可写"; return 1; }
    
    if [ "$(cat "$led_path" 2>/dev/null)" != "$brightness" ]; then
        echo "调试: 设置LED [$led_path] 亮度为 $brightness"
        echo "$brightness" > "$led_path" || echo "错误: 无法设置LED亮度"
    else
        echo "调试: LED [$led_path] 亮度已是 $brightness"
    fi
}

# 获取所有活跃的ATA硬盘ID
get_active_ata_ids() {
    ls -l /sys/block 2>/dev/null | grep -i "ata" | 
    awk -F'ata' '{print "ata"$2}' | awk '{print $1}' | 
    cut -d'/' -f1 | grep -o 'ata[0-9]\+' | sort -u || true
}

# --- 监控逻辑 ---
monitor_disk_leds_loop() {
    echo "启动SATA硬盘LED监控..."
    while true; do
        echo "--- 开始新检测周期 ---"
        
        # 获取所有活跃的ATA ID
        local active_ata_ids=$(get_active_ata_ids)
        echo "调试: 检测到活跃硬盘: ${active_ata_ids:-无}"
        
        # 遍历映射表，同步LED状态
        for ata_id in "${!DISK_LED_MAP[@]}"; do
            local led_file="${DISK_LED_MAP[$ata_id]}"
            local should_be_on=0
            
            # 检查该ATA ID是否活跃
            if echo "$active_ata_ids" | grep -q "\b$ata_id\b"; then
                should_be_on=1
                echo "调试: $ata_id 处于活跃状态"
            else
                echo "调试: $ata_id 处于非活跃状态"
            fi
            
            # 设置LED状态
            set_led_brightness "$led_file" "$should_be_on"
        done
        
        echo "本轮检测完成，等待5秒..."
        sleep 5
    done
}

# 启动监控
monitor_disk_leds_loop
