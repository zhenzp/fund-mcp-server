@echo off
chcp 65001 >nul

echo 🚀 Fund MCP Server 部署工具
echo ================================
echo.

echo 请选择部署方式：
echo 1. 快速部署 (开发环境)
echo 2. 生产环境部署
echo 3. Docker 部署
echo 4. 查看部署说明
echo 5. 退出
echo.

set /p choice=请输入选择 (1-5): 

if "%choice%"=="1" (
    echo.
    echo 🚀 启动快速部署...
    call scripts\deploy.bat
) else if "%choice%"=="2" (
    echo.
    echo 🏭 启动生产环境部署...
    echo 注意：生产环境部署需要Linux系统
    echo 请参考 scripts\DEPLOYMENT.md 获取详细说明
    pause
) else if "%choice%"=="3" (
    echo.
    echo 🐳 启动Docker部署...
    cd scripts
    docker-compose up -d
    echo.
    echo Docker部署完成！服务运行在 http://localhost:3000
    pause
) else if "%choice%"=="4" (
    echo.
    echo 📖 打开部署说明...
    start scripts\README.md
    echo 部署说明已打开，请查看详细文档
    pause
) else if "%choice%"=="5" (
    echo.
    echo 👋 再见！
    exit /b 0
) else (
    echo.
    echo ❌ 无效选择，请重新运行脚本
    pause
    exit /b 1
)
