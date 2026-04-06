#!/bin/bash
# 代理环境配置脚本

set -e

# 默认配置
PROXY_HOST="127.0.0.1"
PROXY_PORT="1080"

# 显示帮助信息
show_help() {
    echo "=========================================="
    echo "        代理环境配置脚本"
    echo "=========================================="
    echo "用法: $0 [选项] [命令]"
    echo ""
    echo "选项:"
    echo "  -h, --host HOST      代理主机 (默认: ${PROXY_HOST})"
    echo "  -p, --port PORT      代理端口 (默认: ${PROXY_PORT})"
    echo "  -s, --shell SHELL    Shell 类型 (auto|bash|zsh|fish)"
    echo "  -c, --check          仅检查代理状态"
    echo "  -r, --remove         移除代理配置"
    echo "  --help               显示此帮助信息"
    echo ""
    echo "命令:"
    echo "  在代理环境中执行指定命令"
    echo ""
    echo "示例:"
    echo "  $0                                    # 显示代理配置"
    echo "  $0 --check                           # 检查代理状态"
    echo "  $0 -c                                # 移除代理配置"
    echo "  $0 curl https://httpbin.org/ip       # 使用代理执行命令"
    echo "  $0 -p 1080 wget https://example.com   # 自定义端口执行命令"
    echo ""
    echo "环境变量:"
    echo "  export http_proxy=socks5h://${PROXY_HOST}:${PROXY_PORT}"
    echo "  export https_proxy=socks5h://${PROXY_HOST}:${PROXY_PORT}"
    echo "  export all_proxy=socks5h://${PROXY_HOST}:${PROXY_PORT}"
}

# 检测 Shell 类型
detect_shell() {
    if [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$FISH_VERSION" ]; then
        echo "fish"
    else
        echo "bash"  # 默认
    fi
}

# 设置代理环境
setup_proxy() {
    local host="$1"
    local port="$2"
    
    export http_proxy="socks5h://${host}:${port}"
    export https_proxy="socks5h://${host}:${port}"
    export all_proxy="socks5h://${host}:${port}"
    
    echo "✅ 代理环境已设置"
    echo "   HTTP_PROXY: $http_proxy"
    echo "   HTTPS_PROXY: $https_proxy"
    echo "   ALL_PROXY: $all_proxy"
}

# 移除代理环境
remove_proxy() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
    
    echo "❌ 代理环境已移除"
}

# 检查代理状态
check_proxy() {
    echo "=========================================="
    echo "           代理状态检查"
    echo "=========================================="
    
    if [ -n "$http_proxy" ]; then
        echo "🟢 代理已配置:"
        echo "   HTTP_PROXY: $http_proxy"
        echo "   HTTPS_PROXY: $https_proxy"
        echo "   ALL_PROXY: $all_proxy"
        echo ""
        
        # 测试代理连接
        echo "🧪 测试代理连接..."
        if command -v curl >/dev/null 2>&1; then
            if curl -s --connect-timeout 5 --socks5 "${PROXY_HOST}:${PROXY_PORT}" https://httpbin.org/ip >/dev/null 2>&1; then
                echo "✅ 代理连接正常"
                echo "🌐 当前出口IP:"
                curl -s --socks5 "${PROXY_HOST}:${PROXY_PORT}" https://httpbin.org/ip | grep -o '"origin": "[^"]*"' | cut -d'"' -f4
            else
                echo "❌ 代理连接失败"
                echo "💡 请检查:"
                echo "   - Chisel 客户端是否正常运行"
                echo "   - 代理端口 ${PROXY_PORT} 是否正确"
                echo "   - 防火墙设置"
            fi
        else
            echo "⚠️  未找到 curl 命令，无法测试代理"
        fi
    else
        echo "🔴 未配置代理"
    fi
}

# 显示配置信息
show_config() {
    echo "=========================================="
    echo "           代理配置信息"
    echo "=========================================="
    echo "代理类型: SOCKS5"
    echo "代理地址: ${PROXY_HOST}:${PROXY_PORT}"
    echo "协议转换: socks5h (DNS 通过代理解析)"
    echo ""
    echo "📋 环境变量配置:"
    echo "export http_proxy=socks5h://${PROXY_HOST}:${PROXY_PORT}"
    echo "export https_proxy=socks5h://${PROXY_HOST}:${PROXY_PORT}"
    echo "export all_proxy=socks5h://${PROXY_HOST}:${PROXY_PORT}"
    echo ""
    echo "🔧 常用工具配置:"
    echo "# Git"
    echo "git config --global http.proxy 'socks5h://${PROXY_HOST}:${PROXY_PORT}'"
    echo "git config --global https.proxy 'socks5h://${PROXY_HOST}:${PROXY_PORT}'"
    echo ""
    echo "# npm (可选)"
    echo "npm config set proxy 'socks5h://${PROXY_HOST}:${PROXY_PORT}'"
    echo "npm config set https-proxy 'socks5h://${PROXY_HOST}:${PROXY_PORT}'"
    echo ""
    echo "# Docker (可选)"
    echo "export HTTP_PROXY=socks5h://${PROXY_HOST}:${PROXY_PORT}"
    echo "export HTTPS_PROXY=socks5h://${PROXY_HOST}:${PROXY_PORT}"
}

# 解析命令行参数
SHELL_TYPE="auto"
CHECK_ONLY=false
REMOVE_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            PROXY_HOST="$2"
            shift 2
            ;;
        -p|--port)
            PROXY_PORT="$2"
            shift 2
            ;;
        -s|--shell)
            SHELL_TYPE="$2"
            shift 2
            ;;
        -c|--check)
            CHECK_ONLY=true
            shift
            ;;
        -r|--remove)
            REMOVE_ONLY=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        -*)
            echo "❌ 未知选项: $1"
            show_help
            exit 1
            ;;
        *)
            # 剩余参数作为命令执行
            break
            ;;
    esac
done

# 执行相应操作
if [ "$CHECK_ONLY" = true ]; then
    check_proxy
elif [ "$REMOVE_ONLY" = true ]; then
    remove_proxy
elif [ $# -gt 0 ]; then
    # 设置代理并执行命令
    setup_proxy "$PROXY_HOST" "$PROXY_PORT"
    echo ""
    echo "🚀 执行命令: $*"
    echo "---"
    exec "$@"
else
    # 显示配置信息
    show_config
fi