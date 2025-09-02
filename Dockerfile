# 使用官方Node.js运行时作为基础镜像
FROM node:lts-alpine  

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production && npm cache clean --force

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 创建非root用户
RUN addgroup -g 1001 -S nodejs
RUN adduser -S fund-mcp -u 1001

# 创建日志目录并设置权限
RUN mkdir -p /app/logs && chown -R fund-mcp:nodejs /app

# 启动命令
CMD ["node", "dist/index.js"]
