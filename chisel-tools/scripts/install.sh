#!/bin/bash
# Chisel 安装脚本

set -e

CHISEL_VERSION="1.9.1"
ARCH="linux_amd64"
DOWNLOAD_URL="https://gh-proxy.com/https://github.com/jpillora/chisel/releases/download/v${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_${ARCH}.gz"

echo "=========================================="
echo "          Chisel 安装脚本"
echo "=========================================="
echo "版本: ${CHISEL_VERSION}"
echo "架构: ${ARCH}"
echo "=========================================="

# 检查是否已存在
if [ -f "./chisel" ]; then
    echo "⚠️  检测到已存在的 chisel 文件"
    read -p "是否覆盖安装? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 安装已取消"
        exit 1
    fi
fi

echo "📥 正在下载 Chisel..."
wget "$DOWNLOAD_URL" -O chisel.gz

echo "📦 正在解压..."
gunzip chisel.gz

echo "🔐 正在赋权..."
chmod +x chisel

echo "🧪 验证安装..."
./chisel version

echo ""
echo "✅ Chisel 安装完成！"
echo ""
echo "📋 使用说明："
echo "  服务端启动: ./chisel server --port 7000 --auth 'admin:password123' --reverse --socks5"
echo "  客户端连接: ./chisel client --auth 'admin:password123' --keepalive 25s <server-url> <config>"
echo ""
echo "💡 提示: 请务必修改默认的认证密码！"