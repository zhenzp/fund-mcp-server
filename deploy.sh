#!/bin/bash

# Fund MCP Server 部署工具
# 适用于Linux/macOS系统

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 显示菜单
show_menu() {
    clear
    echo -e "${CYAN}🚀 Fund MCP Server 部署工具${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
    echo -e "${BLUE}请选择部署方式：${NC}"
    echo "1. 快速部署 (开发环境)"
    echo "2. 生产环境部署"
    echo "3. Docker 部署"
    echo "4. 查看部署说明"
    echo "5. 退出"
    echo ""
}

# 快速部署
quick_deploy() {
    echo -e "${GREEN}🚀 启动快速部署...${NC}"
    if [ -f "scripts/deploy.sh" ]; then
        chmod +x scripts/deploy.sh
        ./scripts/deploy.sh
    else
        echo -e "${RED}❌ 快速部署脚本不存在${NC}"
        exit 1
    fi
}

# 生产环境部署
production_deploy() {
    echo -e "${YELLOW}🏭 启动生产环境部署...${NC}"
    if [ -f "scripts/deploy-production.sh" ]; then
        chmod +x scripts/deploy-production.sh
        echo "请选择操作："
        echo "1. 完整部署 (安装依赖、构建、启动)"
        echo "2. 仅启动服务"
        echo "3. 查看服务状态"
        echo "4. 重启服务"
        echo "5. 停止服务"
        echo "6. 查看日志"
        echo "7. 返回主菜单"
        echo ""
        read -p "请输入选择 (1-7): " sub_choice
        
        case $sub_choice in
            1) ./scripts/deploy-production.sh deploy ;;
            2) ./scripts/deploy-production.sh start ;;
            3) ./scripts/deploy-production.sh status ;;
            4) ./scripts/deploy-production.sh restart ;;
            5) ./scripts/deploy-production.sh stop ;;
            6) ./scripts/deploy-production.sh logs ;;
            7) return ;;
            *) echo -e "${RED}❌ 无效选择${NC}" ;;
        esac
    else
        echo -e "${RED}❌ 生产环境部署脚本不存在${NC}"
        echo "请参考 scripts/DEPLOYMENT.md 获取详细说明"
    fi
    read -p "按回车键继续..."
}

# Docker部署
docker_deploy() {
    echo -e "${BLUE}🐳 启动Docker部署...${NC}"
    if [ -f "scripts/docker-compose.yml" ]; then
        cd scripts
        echo "请选择操作："
        echo "1. 构建并启动服务"
        echo "2. 仅启动服务"
        echo "3. 停止服务"
        echo "4. 查看日志"
        echo "5. 重新构建"
        echo "6. 返回主菜单"
        echo ""
        read -p "请输入选择 (1-6): " docker_choice
        
        case $docker_choice in
            1) docker-compose up -d --build ;;
            2) docker-compose up -d ;;
            3) docker-compose down ;;
            4) docker-compose logs -f ;;
            5) docker-compose up -d --build ;;
            6) cd .. && return ;;
            *) echo -e "${RED}❌ 无效选择${NC}" ;;
        esac
        
        if [ "$docker_choice" != "6" ]; then
            echo ""
            echo -e "${GREEN}Docker操作完成！${NC}"
            if [ "$docker_choice" = "1" ] || [ "$docker_choice" = "2" ] || [ "$docker_choice" = "5" ]; then
                echo -e "${GREEN}服务运行在 http://localhost:3000${NC}"
            fi
        fi
        cd ..
    else
        echo -e "${RED}❌ Docker配置文件不存在${NC}"
    fi
    read -p "按回车键继续..."
}

# 查看部署说明
show_docs() {
    echo -e "${CYAN}📖 部署说明${NC}"
    if [ -f "scripts/README.md" ]; then
        if command -v cat &> /dev/null; then
            cat scripts/README.md
        else
            echo "请手动打开 scripts/README.md 文件查看说明"
        fi
    else
        echo -e "${RED}❌ 部署说明文件不存在${NC}"
    fi
    read -p "按回车键继续..."
}

# 主循环
main() {
    while true; do
        show_menu
        read -p "请输入选择 (1-5): " choice
        
        case $choice in
            1) quick_deploy ;;
            2) production_deploy ;;
            3) docker_deploy ;;
            4) show_docs ;;
            5) 
                echo -e "${GREEN}👋 再见！${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}❌ 无效选择，请重新选择${NC}"
                read -p "按回车键继续..."
                ;;
        esac
    done
}

# 运行主函数
main "$@"
