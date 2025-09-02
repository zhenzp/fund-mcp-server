# Fund MCP Server 部署指南

本文档提供了多种部署 Fund MCP Server 的方法。

## 前置要求

- Node.js 18+ 
- npm 8+
- Git

## 部署方法

### 1. 快速部署脚本

#### Linux/macOS
```bash
# 给脚本执行权限
chmod +x deploy.sh

# 运行部署脚本
./deploy.sh
```

#### Windows
```cmd
# 直接运行批处理文件
deploy.bat
```

### 2. 生产环境部署

#### 使用生产环境脚本
```bash
# 给脚本执行权限
chmod +x deploy-production.sh

# 完整部署（安装依赖、构建、启动服务）
./deploy-production.sh deploy

# 查看服务状态
./deploy-production.sh status

# 查看实时日志
./deploy-production.sh logs

# 重启服务
./deploy-production.sh restart

# 停止服务
./deploy-production.sh stop
```

#### 使用 systemd 服务（推荐用于生产环境）

1. 复制服务文件到系统目录：
```bash
sudo cp fund-mcp-server.service /etc/systemd/system/
```

2. 修改服务文件中的路径和用户：
```bash
sudo nano /etc/systemd/system/fund-mcp-server.service
```

3. 重新加载 systemd 配置：
```bash
sudo systemctl daemon-reload
```

4. 启用并启动服务：
```bash
sudo systemctl enable fund-mcp-server
sudo systemctl start fund-mcp-server
```

5. 查看服务状态：
```bash
sudo systemctl status fund-mcp-server
```

6. 查看日志：
```bash
sudo journalctl -u fund-mcp-server -f
```

### 3. Docker 部署

#### 使用 Docker Compose（推荐）
```bash
# 构建并启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重新构建并启动
docker-compose up -d --build
```

#### 使用 Docker 命令
```bash
# 构建镜像
docker build -t fund-mcp-server .

# 运行容器
docker run -d \
  --name fund-mcp-server \
  -p 3000:3000 \
  -v $(pwd)/logs:/app/logs \
  -v $(pwd)/llm-config.env:/app/llm-config.env:ro \
  fund-mcp-server

# 查看容器日志
docker logs -f fund-mcp-server

# 停止容器
docker stop fund-mcp-server
```

## 配置说明

### 环境变量

创建 `llm-config.env` 文件：
```env
# LLM配置
LLM_API_URL=your_llm_api_url
LLM_API_KEY=your_llm_api_key

# 服务器配置
PORT=3000
NODE_ENV=production
```

### 端口配置

默认端口为 3000，可以通过以下方式修改：

1. 环境变量：`PORT=8080`
2. 命令行参数：`node dist/index.js --http --port 8080`
3. Docker 端口映射：`-p 8080:3000`

## 监控和日志

### 日志文件位置
- 应用日志：`logs/fund-mcp-server.log`
- 错误日志：`logs/fund-mcp-server-error.log`

### 健康检查
服务提供健康检查端点：`http://localhost:3000/health`

### 监控命令
```bash
# 查看服务状态
./deploy-production.sh status

# 查看实时日志
./deploy-production.sh logs

# 查看系统资源使用
top -p $(cat fund-mcp-server.pid)

# 查看端口占用
netstat -tlnp | grep :3000
```

## 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 查看端口占用
   lsof -i :3000
   
   # 杀死占用进程
   kill -9 <PID>
   ```

2. **权限问题**
   ```bash
   # 设置正确的文件权限
   chmod +x dist/*.js
   chown -R www-data:www-data /opt/fund-mcp-server
   ```

3. **依赖安装失败**
   ```bash
   # 清理缓存重新安装
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

4. **服务无法启动**
   ```bash
   # 检查日志
   tail -f logs/fund-mcp-server-error.log
   
   # 检查配置文件
   cat llm-config.env
   ```

### 性能优化

1. **使用 PM2 进行进程管理**
   ```bash
   npm install -g pm2
   pm2 start dist/index.js --name fund-mcp-server
   pm2 startup
   pm2 save
   ```

2. **使用 Nginx 反向代理**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

## 安全建议

1. 使用非 root 用户运行服务
2. 配置防火墙规则
3. 使用 HTTPS（生产环境）
4. 定期更新依赖包
5. 监控系统资源使用

## 备份和恢复

### 备份
```bash
# 备份应用文件
tar -czf fund-mcp-server-backup-$(date +%Y%m%d).tar.gz \
  --exclude=node_modules \
  --exclude=dist \
  --exclude=logs \
  .

# 备份日志
tar -czf logs-backup-$(date +%Y%m%d).tar.gz logs/
```

### 恢复
```bash
# 解压备份文件
tar -xzf fund-mcp-server-backup-YYYYMMDD.tar.gz

# 重新部署
./deploy-production.sh deploy
```
