# Chisel 内网穿透工具

一个基于 Chisel 的内网穿透解决方案，支持反向隧道和 SOCKS5 代理，适用于 Cloud Studio 环境。

## 🚀 快速开始

### 1. 安装 Chisel

```bash
bash scripts/install.sh
```

这将下载并安装 Chisel v1.9.1 到当前目录。

### 2. 服务端启动

在 Cloud Studio 实例中启动服务端：

```bash
# 使用默认配置（端口 7000，认证 admin:password123）
bash scripts/server.sh

# 自定义配置
bash scripts/server.sh -p 8080 -a 'user:pass'
```

**启动后请复制 Cloud Studio 提供的访问 URL**，格式如：
```
https://[实例ID]--[端口].[区域].cloudstudio.club
```

### 3. 客户端连接

在本地机器连接到服务端：

```bash
# SOCKS5 代理模式（默认）
bash scripts/client.sh https://[实例ID]--[端口].[区域].cloudstudio.club

# 开启所有功能（代理 + 反向映射）
bash scripts/client.sh https://[实例ID]--[端口].[区域].cloudstudio.club all

# 仅反向端口映射
bash scripts/client.sh https://[实例ID]--[端口].[区域].cloudstudio.club reverse
```

## 📋 功能说明

### 服务端功能
- **反向隧道支持**：允许内网服务暴露到外网
- **SOCKS5 代理**：提供完整的代理服务
- **认证保护**：支持用户名密码认证
- **自定义端口**：可配置监听端口

### 客户端模式

#### 1. SOCKS5 代理模式（默认）
- **代理端口**：1080（支持局域网访问）
- **用途**：为本地应用提供网络代理
- **测试命令**：
  ```bash
  curl --socks5 127.0.0.1:1080 https://httpbin.org/ip
  ```

#### 2. 反向端口映射模式
默认端口映射：
- **SSH**：`20022 → 127.0.0.1:22`
- **Web**：`28080 → 127.0.0.1:8080`
- **MySQL**：`23306 → 127.0.0.1:3306`

#### 3. 全功能模式（all）
同时启用 SOCKS5 代理和反向端口映射。

## 🛠️ 代理环境配置

使用代理配置脚本快速设置环境变量：

```bash
# 检查代理状态
bash scripts/proxy-setup.sh --check

# 在代理环境中执行命令
bash scripts/proxy-setup.sh curl https://httpbin.org/ip

# 移除代理配置
bash scripts/proxy-setup.sh --remove
```

### 手动配置环境变量

```bash
export http_proxy=socks5h://127.0.0.1:1080
export https_proxy=socks5h://127.0.0.1:1080
export all_proxy=socks5h://127.0.0.1:1080
```

### 常用工具代理配置

```bash
# Git
git config --global http.proxy 'socks5h://127.0.0.1:1080'
git config --global https.proxy 'socks5h://127.0.0.1:1080'

# npm
npm config set proxy 'socks5h://127.0.0.1:1080'
npm config set https-proxy 'socks5h://127.0.0.1:1080'
```

## 📁 脚本说明

| 脚本文件 | 功能描述 |
|---------|---------|
| `scripts/install.sh` | 自动下载并安装 Chisel 二进制文件 |
| `scripts/server.sh` | 启动 Chisel 服务端（支持反向隧道和代理） |
| `scripts/client.sh` | 连接到服务端（支持多种模式） |
| `scripts/proxy-setup.sh` | 代理环境配置和管理工具 |

## 🔧 自定义配置

### 服务端自定义启动参数

```bash
bash scripts/server.sh -p 9000 -a 'myuser:mypass123'
```

参数说明：
- `-p, --port`：监听端口（默认 7000）
- `-a, --auth`：认证信息（默认 admin:password123）

### 客户端自定义连接参数

```bash
bash scripts/client.sh https://server-url all -a 'user:pass' -k 30s
```

参数说明：
- `server_url`：服务器 URL（必填）
- `mode`：连接模式（proxy/reverse/all，默认 proxy）
- `-a, --auth`：认证信息
- `-k, --keepalive`：保活时间（默认 25s）

## 🌐 Cloud Studio 集成

本工具专为 Cloud Studio 环境优化：

1. **自动 URL 生成**：Cloud Studio 自动生成 HTTPS 访问地址
2. **端口映射**：通过 URL 中的端口直接访问内网服务
3. **跨区域支持**：支持所有 Cloud Studio 部署区域

### 获取 Cloud Studio URL

1. 在 Cloud Studio 中启动服务端
2. 查看控制台输出的访问 URL
3. 复制完整 URL 用于客户端连接

## ⚠️ 安全提醒

1. **修改默认密码**：请务必修改默认的认证密码
2. **网络隔离**：仅在可信网络环境中使用
3. **访问控制**：建议限制允许访问的客户端 IP
4. **端口管理**：避免使用系统保留端口

## 🔍 故障排除

### 常见问题

**1. 连接失败**
```bash
# 检查服务端是否启动
netstat -tlnp | grep 7000

# 检查网络连通性
curl -I https://[server-url]
```

**2. 代理无效**
```bash
# 检查代理状态
bash scripts/proxy-setup.sh --check

# 测试代理连接
curl --socks5 127.0.0.1:1080 https://httpbin.org/ip
```

**3. 端口映射无效**
- 检查目标服务是否运行
- 确认防火墙设置
- 验证端口映射配置

### 调试模式

使用 Chisel 原生命令进行调试：

```bash
# 服务端调试
./chisel server --port 7000 --auth 'admin:password123' --reverse --socks5 -v

# 客户端调试
./chisel client --auth 'admin:password123' --keepalive 25s https://server-url 0.0.0.0:1080:socks -v
```

## 📖 详细文档

- [Chisel 官方文档](https://github.com/jpillora/chisel)
- [Cloud Studio 使用指南](https://cloudstudio.tencent.com/)
- [SOCKS5 代理协议说明](https://tools.ietf.org/html/rfc1928)