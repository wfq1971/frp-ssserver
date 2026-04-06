#!/bin/bash
# Chisel 服务端启动脚本

set -e

# 默认配置
DEFAULT_PORT="7000"
DEFAULT_AUTH="admin:password123"

# 显示帮助信息
show_help() {
    echo "=========================================="
    echo "        Chisel 服务端启动脚本"
    echo "=========================================="
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p, --port PORT        监听端口 (默认: ${DEFAULT_PORT})"
    echo "  -a, --auth AUTH        认证信息 (默认: ${DEFAULT_AUTH})"
    echo "  -h, --help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                                    # 使用默认配置"
    echo "  $0 -p 8080 -a 'user:pass'            # 自定义端口和认证"
    echo "  $0 --port 9000 --auth 'myuser:mypass' # 长参数格式"
    echo ""
    echo "⚠️  安全提醒: 请使用强密码替换默认认证！"
}

# 解析命令行参数
PORT="$DEFAULT_PORT"
AUTH="$DEFAULT_AUTH"

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -a|--auth)
            AUTH="$2"
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
echo "        Chisel 服务端配置"
echo "=========================================="
echo "监听端口: ${PORT}"
echo "认证信息: ${AUTH}"
echo "启动模式: 反向隧道 + SOCKS5 代理"
echo "=========================================="

# 检查 chisel 是否存在
if [ ! -f "./chisel" ]; then
    echo "❌ 未找到 chisel 文件，请先运行安装脚本"
    echo "   bash scripts/install.sh"
    exit 1
fi

echo "🚀 正在启动 Chisel 服务端..."
echo "📝 启动命令: ./chisel server --port ${PORT} --auth '${AUTH}' --reverse --socks5"
echo ""
echo "💡 提示:"
echo "  - 服务启动后，请复制 Cloud Studio 的访问 URL"
echo "  - Cloud Studio URL 格式: https://[实例ID]--[端口].[区域].cloudstudio.club"
echo "  - 示例: https://4f5f5a406f5e4a28b6038ca1a374a8db--7000.ap-shanghai2.cloudstudio.club"
echo "  - 客户端连接时请使用完整的 HTTPS URL"
echo "  - 按 Ctrl+C 可停止服务"
echo ""

# 启动服务
exec ./chisel server --port "$PORT" --auth "$AUTH" --reverse --socks5