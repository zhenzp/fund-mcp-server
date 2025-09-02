#!/bin/bash

# Fund MCP Server 生产环境部署脚本
# 适用于Linux服务器环境

set -e

# 配置
APP_NAME="fund-mcp-server"
APP_DIR=$(pwd)
LOG_DIR="$APP_DIR/logs"
PID_FILE="$APP_DIR/fund-mcp-server.pid"
LOG_FILE="$LOG_DIR/fund-mcp-server.log"
ERROR_LOG="$LOG_DIR/fund-mcp-server-error.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >> "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $1" >> "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >> "$ERROR_LOG"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 未安装，请先安装 $1"
        exit 1
    fi
}

# 创建必要的目录
create_directories() {
    mkdir -p "$LOG_DIR"
    log_success "创建日志目录: $LOG_DIR"
}

# 检查服务是否正在运行
is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PID_FILE"
        fi
    fi
    return 1
}

# 停止服务
stop_service() {
    if is_running; then
        local pid=$(cat "$PID_FILE")
        log_info "停止服务 (PID: $pid)..."
        kill "$pid" 2>/dev/null || true
        sleep 2
        if ps -p "$pid" > /dev/null 2>&1; then
            log_warning "服务未正常停止，强制终止..."
            kill -9 "$pid" 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
        log_success "服务已停止"
    else
        log_info "服务未运行"
    fi
}

# 启动服务
start_service() {
    if is_running; then
        log_warning "服务已在运行中"
        return 0
    fi
    
    log_info "启动服务..."
    
    # 启动服务到后台
    nohup node dist/index.js --http > "$LOG_FILE" 2> "$ERROR_LOG" &
    local pid=$!
    echo "$pid" > "$PID_FILE"
    
    # 等待服务启动
    sleep 3
    
    if ps -p "$pid" > /dev/null 2>&1; then
        log_success "服务启动成功 (PID: $pid)"
        log_info "日志文件: $LOG_FILE"
        log_info "错误日志: $ERROR_LOG"
        log_info "PID文件: $PID_FILE"
    else
        log_error "服务启动失败"
        rm -f "$PID_FILE"
        exit 1
    fi
}

# 重启服务
restart_service() {
    log_info "重启服务..."
    stop_service
    sleep 2
    start_service
}

# 查看服务状态
status_service() {
    if is_running; then
        local pid=$(cat "$PID_FILE")
        log_success "服务正在运行 (PID: $pid)"
        echo "进程信息:"
        ps -p "$pid" -o pid,ppid,cmd,etime
        echo ""
        echo "最近日志 (最后10行):"
        tail -n 10 "$LOG_FILE" 2>/dev/null || echo "暂无日志"
    else
        log_warning "服务未运行"
    fi
}

# 查看日志
view_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "=== 应用日志 ==="
        tail -f "$LOG_FILE"
    else
        log_warning "日志文件不存在"
    fi
}

# 部署应用
deploy_app() {
    log_info "开始部署应用..."
    
    # 检查环境
    check_command "node"
    check_command "npm"
    
    # 创建目录
    create_directories
    
    # 停止现有服务
    stop_service
    
    # 清理构建文件
    log_info "清理旧的构建文件..."
    rm -rf dist
    
    # 安装依赖
    log_info "安装项目依赖..."
    npm install --production=false
    if [ $? -ne 0 ]; then
        log_error "依赖安装失败"
        exit 1
    fi
    
    # 构建项目
    log_info "构建项目..."
    npm run build
    if [ $? -ne 0 ]; then
        log_error "项目构建失败"
        exit 1
    fi
    
    # 检查构建结果
    if [ ! -f "dist/index.js" ]; then
        log_error "构建失败：dist/index.js 文件不存在"
        exit 1
    fi
    
    # 设置权限
    chmod +x dist/*.js
    
    log_success "部署完成"
}

# 显示帮助信息
show_help() {
    echo "Fund MCP Server 生产环境管理脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  deploy     - 部署应用（安装依赖、构建、启动服务）"
    echo "  start      - 启动服务"
    echo "  stop       - 停止服务"
    echo "  restart    - 重启服务"
    echo "  status     - 查看服务状态"
    echo "  logs       - 查看实时日志"
    echo "  help       - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 deploy    # 完整部署"
    echo "  $0 start     # 启动服务"
    echo "  $0 status    # 查看状态"
}

# 主函数
main() {
    case "${1:-help}" in
        deploy)
            deploy_app
            start_service
            ;;
        start)
            start_service
            ;;
        stop)
            stop_service
            ;;
        restart)
            restart_service
            ;;
        status)
            status_service
            ;;
        logs)
            view_logs
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
