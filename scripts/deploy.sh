#!/bin/bash

# Fund MCP Server 部署脚本
# 适用于Linux服务器环境

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 未安装，请先安装 $1"
        exit 1
    fi
}

# 主函数
main() {
    log_info "🚀 开始部署 Fund MCP Server..."
    
    # 检查必要的命令
    log_info "检查系统环境..."
    check_command "node"
    check_command "npm"
    
    # 显示版本信息
    log_info "Node.js 版本: $(node --version)"
    log_info "npm 版本: $(npm --version)"
    
    # 清理旧的构建文件
    log_info "清理旧的构建文件..."
    if [ -d "dist" ]; then
        rm -rf dist
        log_success "已清理 dist 目录"
    fi
    
    if [ -d "node_modules" ]; then
        log_warning "检测到 node_modules 目录，是否删除重新安装？(y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            rm -rf node_modules
            log_success "已清理 node_modules 目录"
        fi
    fi
    
    # 安装依赖
    log_info "📦 安装项目依赖..."
    npm install
    if [ $? -eq 0 ]; then
        log_success "依赖安装完成"
    else
        log_error "依赖安装失败"
        exit 1
    fi
    
    # 构建项目
    log_info "🔨 构建项目..."
    npm run build
    if [ $? -eq 0 ]; then
        log_success "项目构建完成"
    else
        log_error "项目构建失败"
        exit 1
    fi
    
    # 检查构建结果
    if [ ! -f "dist/index.js" ]; then
        log_error "构建失败：dist/index.js 文件不存在"
        exit 1
    fi
    
    # 设置文件权限
    log_info "设置文件权限..."
    chmod +x dist/*.js
    log_success "文件权限设置完成"
    
    # 启动HTTP服务
    log_info "🔗 启动HTTP服务器..."
    log_info "服务将在后台运行，日志将输出到控制台"
    log_info "按 Ctrl+C 停止服务"
    
    # 启动服务
    npm run start:http
}

# 错误处理
trap 'log_error "部署过程中发生错误，退出码: $?"' ERR

# 运行主函数
main "$@"
