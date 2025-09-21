#!/bin/bash

# 简化版系统检测脚本（支持Linux和FreeBSD）

# 检测系统类型
system_type=$(uname -s)

if [ "$system_type" = "FreeBSD" ]; then
    # FreeBSD系统检测
    if command -v freebsd-version >/dev/null 2>&1; then
        version=$(freebsd-version -u)
    else
        version=$(uname -r)
    fi
    echo "系统类型: FreeBSD"
    echo "版本号: $version"
    
elif [ "$system_type" = "Linux" ]; then
    # Linux系统检测
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "系统类型: $NAME"
        echo "版本号: $VERSION_ID"
    elif [ -f /etc/redhat-release ]; then
        echo "系统类型: Red Hat/CentOS"
        echo "版本号: $(cat /etc/redhat-release | sed 's/.*release \([0-9.]*\).*/\1/')"
    elif [ -f /etc/debian_version ]; then
        echo "系统类型: Debian"
        echo "版本号: $(cat /etc/debian_version)"
    else
        echo "系统类型: $(uname -s)"
        echo "版本号: $(uname -r)"
    fi
else
    echo "系统类型: $system_type"
    echo "版本号: $(uname -r)"
fi
