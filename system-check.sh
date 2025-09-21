#!/bin/bash

# 自动检测系统类型和版本号脚本（支持Linux和FreeBSD）

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 函数：输出带颜色的信息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_system() {
    echo -e "${CYAN}[SYSTEM]${NC} $1"
}

# 函数：检测Linux系统信息
detect_linux_os() {
    local os_name=""
    local os_version=""
    local os_id=""
    
    # 检查 /etc/os-release 文件 (大多数现代Linux发行版)
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_name="$NAME"
        os_version="$VERSION_ID"
        os_id="$ID"
        
    # 检查 /etc/lsb-release 文件 (Ubuntu和其他基于Debian的系统)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        os_name="$DISTRIB_ID"
        os_version="$DISTRIB_RELEASE"
        os_id=$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
        
    # 检查 /etc/redhat-release 文件 (Red Hat/CentOS)
    elif [ -f /etc/redhat-release ]; then
        os_name=$(cat /etc/redhat-release | sed 's/release//g' | awk '{print $1}')
        os_version=$(cat /etc/redhat-release | sed 's/.*release \([0-9.]*\).*/\1/')
        os_id=$(echo "$os_name" | tr '[:upper:]' '[:lower:]')
        
    # 检查 /etc/debian_version 文件 (Debian)
    elif [ -f /etc/debian_version ]; then
        os_name="Debian"
        os_version=$(cat /etc/debian_version)
        os_id="debian"
        
    # 其他特殊情况
    else
        # 尝试使用 uname 命令作为最后的手段
        os_name=$(uname -s)
        os_version=$(uname -r)
        os_id="unknown"
    fi
    
    # 输出结果
    echo "$os_name $os_version $os_id"
}

# 函数：检测FreeBSD系统信息
detect_freebsd_os() {
    local os_name="FreeBSD"
    local os_version=""
    local os_id="freebsd"
    
    # 获取FreeBSD版本信息
    if command -v freebsd-version >/dev/null 2>&1; then
        os_version=$(freebsd-version -u)
    else
        os_version=$(uname -r)
    fi
    
    echo "$os_name $os_version $os_id"
}

# 函数：检测系统类型
detect_system_type() {
    case $(uname -s) in
        Linux)
            echo "linux"
            ;;
        FreeBSD)
            echo "freebsd"
            ;;
        Darwin)
            echo "macos"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# 函数：获取内核信息
get_kernel_info() {
    case $(detect_system_type) in
        linux)
            echo "$(uname -s) $(uname -r)"
            ;;
        freebsd)
            echo "FreeBSD $(uname -r)"
            ;;
        *)
            echo "$(uname -s) $(uname -r)"
            ;;
    esac
}

# 函数：获取系统架构
get_architecture() {
    echo "$(uname -m)"
}

# 函数：获取FreeBSD额外信息
get_freebsd_info() {
    local info=""
    
    # 获取pkg管理器信息
    if command -v pkg >/dev/null 2>&1; then
        info="pkg管理器: $(pkg -v)"
    fi
    
    # 获取FreeBSD的升级信息
    if command -v freebsd-update >/dev/null 2>&1; then
        info="$info, 支持freebsd-update"
    fi
    
    echo "$info"
}

# 主函数
main() {
    print_info "开始检测系统信息..."
    echo "=========================================="
    
    # 检测系统类型
    system_type=$(detect_system_type)
    
    # 根据系统类型检测信息
    case $system_type in
        linux)
            os_info=$(detect_linux_os)
            ;;
        freebsd)
            os_info=$(detect_freebsd_os)
            ;;
        *)
            os_info="Unknown $(uname -s) $(uname -r) unknown"
            ;;
    esac
    
    os_name=$(echo $os_info | awk '{print $1}')
    os_version=$(echo $os_info | awk '{print $2}')
    os_id=$(echo $os_info | awk '{print $3}')
    
    # 获取其他系统信息
    kernel_info=$(get_kernel_info)
    architecture=$(get_architecture)
    
    # 输出系统信息
    print_system "操作系统: $(uname -s)"
    print_system "系统类型: $os_name"
    print_system "系统版本: $os_version"
    print_system "系统ID: $os_id"
    print_system "内核信息: $kernel_info"
    print_system "系统架构: $architecture"
    
    # FreeBSD特定信息
    if [ "$system_type" = "freebsd" ]; then
        freebsd_info=$(get_freebsd_info)
        if [ -n "$freebsd_info" ]; then
            print_system "FreeBSD信息: $freebsd_info"
        fi
    fi
    
    echo "=========================================="
    
    # 根据检测到的系统类型提供特定信息
    case $os_id in
        ubuntu|debian)
            print_info "这是一个基于Debian的Linux系统"
            ;;
        centos|rhel|fedora|redhat)
            print_info "这是一个基于Red Hat的Linux系统"
            ;;
        arch)
            print_info "这是一个Arch Linux系统"
            ;;
        alpine)
            print_info "这是一个Alpine Linux系统"
            ;;
        freebsd)
            print_info "这是一个FreeBSD系统"
            ;;
        *)
            print_warning "未知或不受支持的系统类型: $os_id"
            ;;
    esac
    
    print_info "系统检测完成!"
}

# 执行主函数
main "$@"
