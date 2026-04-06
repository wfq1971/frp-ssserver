#!/bin/bash
# Chisel 客户端连接脚本

set -e

# 默认配置
DEFAULT_AUTH="admin:password123"
DEFAULT_KEEPALIVE="25s"

# 显示帮助信息
show_help() {
    echo "=========================================="
    echo "        Chisel 客户端连接脚本"
    echo "=========================================="
    echo "用法: $0 <server_url> [模式] [选项]"
    echo ""
    echo "参数:"
    echo "  server_url             服务器 URL (必填)"
    echo "                         格式: https://[实例ID]--[端口].[区域].cloudstudio.club"
    echo "  mode                   连接模式 (默认: proxy)"
    echo "                         可选: proxy, reverse, all"
    echo ""
    echo "选项:"
    echo "  -a, --auth AUTH        认证信息 (默认: ${DEFAULT_AUTH})"
    echo "  -k, --keepalive TIME   保活时间 (默认: ${DEFAULT_KEEPALIVE})"
    echo "  -c, --config FILE      自定义配置文件"
    echo "  -h, --help             显示此帮助信息"
    echo ""
    echo "模式说明:"
    echo "  proxy    - 仅开启 SOCKS5 代理 (端口 1080)"
    echo "  reverse  - 仅开启反向端口映射"
    echo "  all      - 开启所有功能 (代理 + 映射)"
    echo ""
    echo "示例:"
    echo "  $0 https://4f5f5a40--7000.ap-shanghai2.cloudstudio.club  # 默认代理模式"
    echo "  $0 https://4f5f5a40--7000.ap-shanghai2.cloudstudio.club all  # 开启所有功能"
    echo "  $0 https://[实例ID]--[端口].[区域].cloudstudio.club reverse  # 仅反向映射"
    echo "  $0 https://[实例ID]--[端口].[区域].cloudstudio.club all -a 'user:pass'  # 自定义认证"
    echo ""
    echo "默认端口映射:"
    echo "  - SSH:      20022 -> 127.0.0.1:22"
    echo "  - Web:      28080 -> 127.0.0.1:8080"
    echo "  - MySQL:    23306 -> 127.0.0.1:3306"
    echo "  - SOCKS5:   1080"
}

# 解析命令行参数
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

SERVER_URL="$1"
MODE="${2:-proxy}"
AUTH="$DEFAULT_AUTH"
KEEPALIVE="$DEFAULT_KEEPALIVE"
CONFIG_FILE=""

# 只有当有第二个参数时才 shift 2，否则 shift 1
if [ $# -gt 1 ]; then
    shift 2
else
    shift 1
fi
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--auth)
            AUTH="$2"
            shift 2
            ;;
        -k|--keepalive)
            KEEPALIVE="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ 未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 显示配置信息
echo "=========================================="
echo "        Chisel 客户端配置"
echo "=========================================="
echo "服务器: ${SERVER_URL}"
echo "连接模式: ${MODE}"
echo "认证信息: ${AUTH}"
echo "保活时间: ${KEEPALIVE}"
echo "=========================================="

# 检查 chisel 是否存在
if [ ! -f "./chisel" ]; then
    echo "❌ 未找到 chisel 文件，请先运行安装脚本"
    echo "   bash scripts/install.sh"
    exit 1
fi

# 构建连接命令
case $MODE in
    "proxy")
        echo "🔧 模式: SOCKS5 代理"
        echo "📡 代理端口: 1080 (支持局域网访问)"
        echo ""
        CMD="./chisel client --auth '${AUTH}' --keepalive ${KEEPALIVE} '${SERVER_URL}' 0.0.0.0:1080:socks"
        ;;
    "reverse")
        echo "🔧 模式: 反向端口映射"
        echo "📋 端口映射:"
        echo "  - SSH (22)     -> ${SERVER_URL%%:*}:20022"
        echo "  - Web (8080)   -> ${SERVER_URL%%:*}:28080"
        echo "  - MySQL (3306) -> ${SERVER_URL%%:*}:23306"
        echo ""
        CMD="./chisel client --auth '${AUTH}' --keepalive ${KEEPALIVE} '${SERVER_URL}' \
  R:0.0.0.0:44300:127.0.0.1:25569 \
  R:0.0.0.0:28080:127.0.0.1:8080 \
  R:0.0.0.0:23306:127.0.0.1:3306"
        ;;
    "all")
        echo "🔧 模式: 全功能 (代理 + 映射)"
        echo "📡 代理端口: 1080"
        echo "📋 端口映射:"
        echo "  - SSH (22)     -> ${SERVER_URL%%:*}:20022"
        echo "  - Web (8080)   -> ${SERVER_URL%%:*}:28080"
        echo "  - MySQL (3306) -> ${SERVER_URL%%:*}:23306"
        echo ""
        CMD="./chisel client --auth '${AUTH}' --keepalive ${KEEPALIVE} '${SERVER_URL}' \
  0.0.0.0:1080:socks \
  R:0.0.0.0:20022:127.0.0.1:22 \
  R:0.0.0.0:28080:127.0.0.1:8080 \
  R:0.0.0.0:23306:127.0.0.1:3306"
        ;;
    *)
        echo "❌ 未知模式: ${MODE}"
        echo "   支持的模式: proxy, reverse, all"
        exit 1
        ;;
esac

echo "🚀 正在连接到服务器..."
echo "📝 执行命令:"
echo "$CMD"
echo ""
echo "💡 提示:"
echo "  - 连接成功后，按 Ctrl+C 可断开连接"
echo "  - 代理模式下可使用 curl --socks5 127.0.0.1:1080 测试"
echo "  - 反向映射后可通过外网IP:端口访问内网服务"
echo "  - Cloud Studio URL 格式: https://[实例ID]--[端口].[区域].cloudstudio.club"
echo ""

# 执行连接
if [ "$MODE" = "proxy" ]; then
    exec bash -c "$CMD"
else
    exec bash -c "$CMD"
fi
