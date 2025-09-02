# Fund MCP Server

一个基于 Model Context Protocol (MCP) 的基金知识库服务器。



Configure AI application (e.g. Claude Desktop).

```json
{
  "mcpServers": {
    "fund-mcp-server": {
      "command": "npx",
      "args": ["fund-mcp-server"]
    }
  }
}
```


## 快速开始

### 🚀 一键部署

#### Windows 用户

```cmd
# 双击运行或在命令行执行
deploy.bat
```

#### Linux/macOS 用户

```bash
# 给脚本执行权限并运行
chmod +x deploy.sh
./deploy.sh
```

### 📦 手动部署

1. **安装依赖**

   ```bash
   npm install
   ```
2. **构建项目**

   ```bash
   npm run build
   ```
3. **启动服务**

   ```bash
   # HTTP 模式
   npm run start:http

   # SSE 模式
   npm run start:sse
   ```

## 部署选项

### 1. 快速部署 (开发环境)

- **Windows**: `deploy.bat` 或 `scripts\deploy.bat`
- **Linux/macOS**: `./deploy.sh` 或 `./scripts/deploy.sh`

### 2. 生产环境部署

- **Linux**: `./scripts/deploy-production.sh deploy`
- **systemd 服务**: 参考 `scripts/DEPLOYMENT.md`

### 3. Docker 部署

```bash
cd scripts
docker-compose up -d
```

### 4. 查看详细部署说明

- 查看 `scripts/README.md` 获取脚本说明
- 查看 `scripts/DEPLOYMENT.md` 获取详细部署指南

## 项目结构

```
fund-mcp-server/
├── deploy.bat                    # Windows 部署入口
├── deploy.sh                     # Linux/macOS 部署入口
├── scripts/                      # 部署脚本文件夹
│   ├── README.md                # 脚本说明
│   ├── DEPLOYMENT.md            # 详细部署指南
│   ├── deploy.sh                # Linux 快速部署
│   ├── deploy.bat               # Windows 快速部署
│   ├── deploy-production.sh     # 生产环境部署
│   ├── fund-mcp-server.service  # systemd 服务配置
│   ├── Dockerfile               # Docker 镜像
│   └── docker-compose.yml       # Docker Compose
├── src/                         # 源代码
├── dist/                        # 构建输出
└── package.json                 # 项目配置
```

## 配置

### 环境变量

创建 `llm-config.env` 文件：

```env
LLM_API_URL=your_llm_api_url
LLM_API_KEY=your_llm_api_key
PORT=3000
NODE_ENV=production
```

### 端口配置

默认端口：3000

- 环境变量：`PORT=8080`
- 命令行：`--port 8080`

## 开发

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run watch
```

### 构建

```bash
npm run build
```

### 测试

```bash
npm test
```

## 服务管理

### 生产环境

```bash
# 查看状态
./scripts/deploy-production.sh status

# 查看日志
./scripts/deploy-production.sh logs

# 重启服务
./scripts/deploy-production.sh restart
```

### Docker

```bash
# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart
```

## 故障排除

### 常见问题

1. **端口被占用**

   ```bash
   lsof -i :3000
   kill -9 <PID>
   ```
2. **权限问题**

   ```bash
   chmod +x scripts/*.sh
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

## 贡献

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

Apache-2.0

## 支持

- 📖 部署文档：`scripts/DEPLOYMENT.md`
- 🐛 问题反馈：GitHub Issues
- 💬 讨论：GitHub Discussions
