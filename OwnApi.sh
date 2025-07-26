#!/bin/bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
}

# 安装Node.js
install_nodejs() {
    local platform=$(uname -s)
    
    case "$platform" in
        Linux|Darwin)
            print_info "Installing Node.js on Unix/Linux/macOS..."
            
            print_info "Downloading and installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
            
            print_info "Loading nvm environment..."
            \. "$HOME/.nvm/nvm.sh"
            
            print_info "Downloading and installing Node.js v22..."
            nvm install 22
            
            print_success "Node.js installation completed!"
            echo -n "   Version: "
            node -v
            echo -n "   nvm version: "
            nvm current
            echo -n "   npm version: "
            npm -v
            ;;
        *)
            print_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac
}

# 检查并安装依赖
check_and_install_dependencies() {
    print_header "检查系统依赖..."
    
    # 检查 Node.js 是否已安装
    if command -v node >/dev/null 2>&1; then
        current_version=$(node -v | sed 's/v//')
        major_version=$(echo $current_version | cut -d. -f1)
        
        if [ "$major_version" -ge 18 ]; then
            print_success "Node.js is already installed: v$current_version"
        else
            print_warning "Node.js v$current_version is installed but version < 18. Upgrading..."
            install_nodejs
        fi
    else
        print_info "Node.js not found. Installing..."
        install_nodejs
    fi

    # 检查是否安装 claude-code
    if command -v claude >/dev/null 2>&1; then
        print_success "Claude Code is already installed: $(claude --version)"
    else
        print_info "Claude Code not found. Installing..."
        npm install -g @anthropic-ai/claude-code
        print_success "Claude Code installed successfully!"
    fi
}

# 配置Claude Code
configure_claude() {
    print_header "配置 Claude Code..."
    
    # 跳过引导配置
    print_info "Configuring Claude Code to skip onboarding..."
    node --eval '
        const os = require("os");
        const fs = require("fs");
        const path = require("path");
        const homeDir = os.homedir(); 
        const filePath = path.join(homeDir, ".claude.json");
        if (fs.existsSync(filePath)) {
            const content = JSON.parse(fs.readFileSync(filePath, "utf-8"));
            fs.writeFileSync(filePath,JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2), "utf-8");
        } else {
            fs.writeFileSync(filePath,JSON.stringify({ hasCompletedOnboarding: true }, null, 2), "utf-8");
        }'
    print_success "Onboarding configuration completed!"

    # 创建设置文件
    print_info "Creating Claude Code settings..."
    mkdir -p ~/.claude
    cat > ~/.claude/settings.json << EOF
{
  "defaultModel": "anthropic/claude-sonnet-4",
  "fallbackModel": "anthropic/claude-sonnet-4",
  "autoAccept": false,
  "theme": "auto",
  "compactThreshold": 80,
  "compactPeriodDays": 7
}
EOF
    print_success "Settings file created!"
}

# 配置环境变量
setup_environment() {
    print_header "配置环境变量..."
    
    # 用户输入中转 API Key
    echo ""
    print_info "请输入你的中转 API Key："
    echo "   注意：输入内容不会显示，请直接粘贴"
    echo ""
    read -s api_key
    echo ""

    if [ -z "$api_key" ]; then
        print_error "API key 不能为空，请重新运行脚本"
        exit 1
    fi

    # 检测当前 shell 类型
    current_shell=$(basename "$SHELL")
    case "$current_shell" in
        bash)
            rc_file="$HOME/.bashrc"
            ;;
        zsh)
            rc_file="$HOME/.zshrc"
            ;;
        fish)
            rc_file="$HOME/.config/fish/config.fish"
            ;;
        *)
            rc_file="$HOME/.profile"
            ;;
    esac

    # 写入环境变量
    print_info "正在写入环境变量到 $rc_file..."

    # 替换为你的中转地址
    proxy_url=""

    if [ -f "$rc_file" ] && grep -q "ANTHROPIC_BASE_URL\|ANTHROPIC_API_KEY" "$rc_file"; then
        print_warning "环境变量已存在，跳过写入..."
    else
        echo "" >> "$rc_file"
        echo "# Claude Code environment variables" >> "$rc_file"
        echo "export ANTHROPIC_BASE_URL=$proxy_url" >> "$rc_file"
        echo "export ANTHROPIC_API_KEY=$api_key" >> "$rc_file"
        print_success "环境变量已添加至 $rc_file"
    fi

    # 创建别名
    print_info "创建Claude Code别名..."
    if [ -f "$rc_file" ] && grep -q "alias claude=" "$rc_file"; then
        print_warning "别名已存在，跳过创建..."
    else
        echo "" >> "$rc_file"
        echo "# Claude Code alias" >> "$rc_file"
        echo 'alias claude="npx @anthropic-ai/claude-code --model anthropic/claude-sonnet-4"' >> "$rc_file"
        print_success "别名已添加至 $rc_file"
    fi
}

# 启动Claude Code
start_claude() {
    print_header "启动 Claude Code..."
    
    # 检查环境变量
    if [ -z "$ANTHROPIC_BASE_URL" ] || [ -z "$ANTHROPIC_API_KEY" ]; then
        print_warning "环境变量未设置，请先运行安装模式"
        print_info "运行: $0 install"
        exit 1
    fi
    
    echo -e "${CYAN}📝 使用模型: anthropic/claude-sonnet-4${NC}"
    echo -e "${CYAN}🔗 API地址: $ANTHROPIC_BASE_URL${NC}"
    echo ""

    # 启动Claude Code
    npx @anthropic-ai/claude-code --model "anthropic/claude-sonnet-4" "$@"
}

# 测试连接
test_connection() {
    print_header "测试API连接..."
    
    if [ -z "$ANTHROPIC_BASE_URL" ] || [ -z "$ANTHROPIC_API_KEY" ]; then
        print_error "环境变量未设置"
        return 1
    fi
    
    print_info "测试API连接..."
    response=$(curl -s -H "Authorization: Bearer $ANTHROPIC_API_KEY" -H "Content-Type: application/json" \
        -d '{"model":"anthropic/claude-sonnet-4","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}' \
        "$ANTHROPIC_BASE_URL/v1/chat/completions" 2>/dev/null)
    
    if echo "$response" | grep -q "choices"; then
        print_success "API连接测试成功！"
        return 0
    else
        print_error "API连接测试失败"
        echo "响应: $response"
        return 1
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${PURPLE}Claude Code 完整管理脚本${NC}"
    echo ""
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  install    安装和配置 Claude Code"
    echo "  start      启动 Claude Code"
    echo "  test       测试API连接"
    echo "  help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 install    # 安装和配置"
    echo "  $0 start      # 启动Claude Code"
    echo "  $0 test       # 测试连接"
    echo ""
    echo "注意: 首次使用请先运行 'install' 命令"
}

# 主函数
main() {
    case "${1:-start}" in
        install)
            check_and_install_dependencies
            configure_claude
            setup_environment
            echo ""
            print_success "安装和配置完成！"
            echo ""
            print_info "请重新打开终端，或执行以下命令以立即生效："
            echo "   source ~/.${SHELL##*/}rc"
            echo ""
            print_info "然后你就可以使用以下命令启动Claude Code："
            echo "   $0 start"
            echo "   或者直接使用: claude"
            ;;
        start)
            start_claude
            ;;
        test)
            test_connection
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "未知命令: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@" 
