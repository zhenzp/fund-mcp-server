# 部署脚本说明

本文件夹包含 Fund MCP Server 的所有部署相关脚本和配置文件。

## 文件结构

```
scripts/
├── README.md                    # 本说明文件
├── deploy.sh                    # Linux/macOS 快速部署脚本
├── deploy.bat                   # Windows 快速部署脚本
├── deploy-production.sh         # Linux 生产环境部署脚本
├── fund-mcp-server.service      # systemd 服务配置文件
├── Dockerfile                   # Docker 镜像构建文件
├── docker-compose.yml           # Docker Compose 配置文件
└── DEPLOYMENT.md               # 详细部署指南
```

## 快速开始

### Windows 用户
```cmd
# 在项目根目录执行
scripts\deploy.bat
```

### Linux/macOS 用户
```bash
# 在项目根目录执行
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## 部署方式

### 1. 快速部署
- **Windows**: `scripts\deploy.bat`
- **Linux/macOS**: `./scripts/deploy.sh`

适用于开发环境和快速测试。

### 2. 生产环境部署
```bash
# Linux 生产环境
chmod +x scripts/deploy-production.sh
./scripts/deploy-production.sh deploy
```

### 3. Docker 部署
```bash
# 使用 Docker Compose
cd scripts
docker-compose up -d

# 或使用 Docker 命令
docker build -t fund-mcp-server .
docker run -d -p 3000:3000 fund-mcp-server
```

### 4. systemd 服务部署
```bash
# 复制服务文件
sudo cp scripts/fund-mcp-server.service /etc/systemd/system/

# 启用并启动服务
sudo systemctl enable fund-mcp-server
sudo systemctl start fund-mcp-server
```

## 脚本功能

### deploy.sh / deploy.bat
- ✅ 检查 Node.js 和 npm 环境
- 📦 安装项目依赖
- 🔨 构建项目
- 🔗 启动 HTTP 服务

### deploy-production.sh
- 🚀 完整的生产环境部署
- 📊 服务状态管理
- 📝 日志管理
- 🔄 服务重启功能
- 🛡️ 错误处理和监控

### Docker 相关
- 🐳 容器化部署
- 🔍 健康检查
- 📊 日志收集
- 🔄 自动重启

## 常用命令

### 生产环境管理
```bash
# 查看服务状态
./scripts/deploy-production.sh status

# 查看实时日志
./scripts/deploy-production.sh logs

# 重启服务
./scripts/deploy-production.sh restart

# 停止服务
./scripts/deploy-production.sh stop
```

### Docker 管理
```bash
# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重新构建
docker-compose up -d --build
```

## 配置说明

### 环境变量
创建 `llm-config.env` 文件在项目根目录：
```env
LLM_API_URL=your_llm_api_url
LLM_API_KEY=your_llm_api_key
PORT=3000
NODE_ENV=production
```

### 端口配置
默认端口：3000
- 环境变量：`PORT=8080`
- Docker：`-p 8080:3000`
- 命令行：`--port 8080`

## 故障排除

### 常见问题
1. **权限问题**
   ```bash
   chmod +x scripts/*.sh
   ```

2. **端口占用**
   ```bash
   lsof -i :3000
   kill -9 <PID>
   ```

3. **依赖问题**
   ```bash
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

### 日志位置
- 应用日志：`logs/fund-mcp-server.log`
- 错误日志：`logs/fund-mcp-server-error.log`
- Docker 日志：`docker-compose logs`

## 安全建议

1. 🔒 使用非 root 用户运行服务
2. 🛡️ 配置防火墙规则
3. 🔐 使用 HTTPS（生产环境）
4. 📦 定期更新依赖包
5. 📊 监控系统资源使用

## 联系支持

如有问题，请查看 `DEPLOYMENT.md` 获取详细说明。
