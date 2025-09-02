@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 🚀 开始部署 Fund MCP Server...
echo.

echo 📋 检查系统环境...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Node.js 未安装，请先安装 Node.js
    pause
    exit /b 1
)

where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ npm 未安装，请先安装 npm
    pause
    exit /b 1
)

echo ✅ Node.js 版本: 
node --version
echo ✅ npm 版本: 
npm --version
echo.

echo 🧹 清理旧的构建文件...
if exist dist (
    rmdir /s /q dist
    echo ✅ 已清理 dist 目录
)

if exist node_modules (
    echo ⚠️  检测到 node_modules 目录，是否删除重新安装？(Y/N)
    set /p choice=
    if /i "!choice!"=="Y" (
        rmdir /s /q node_modules
        echo ✅ 已清理 node_modules 目录
    )
)
echo.

echo 📦 安装项目依赖...
call npm install
if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)
echo ✅ 依赖安装完成
echo.

echo 🔨 构建项目...
call npm run build
if %errorlevel% neq 0 (
    echo ❌ 项目构建失败
    pause
    exit /b 1
)
echo ✅ 项目构建完成
echo.

echo 🔍 检查构建结果...
if not exist dist\index.js (
    echo ❌ 构建失败：dist\index.js 文件不存在
    pause
    exit /b 1
)
echo ✅ 构建文件检查通过
echo.

echo 🔗 启动HTTP服务器...
echo 服务将启动，按 Ctrl+C 停止服务
echo.
call npm run start:http

pause
