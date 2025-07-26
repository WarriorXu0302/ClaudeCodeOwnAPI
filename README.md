# Claude Code 完整管理脚本

这是一个集成了安装、配置和启动功能的完整Claude Code管理脚本。

## 🚀 功能特性

- ✅ **一键安装**: 自动安装Node.js、nvm和Claude Code
- ✅ **智能配置**: 自动配置环境变量和设置文件
- ✅ **连接测试**: 验证API连接是否正常
- ✅ **彩色输出**: 美观的命令行界面
- ✅ **错误处理**: 完善的错误检查和提示
- ✅ **多平台支持**: 支持Linux、macOS等Unix系统

## 📦 安装和使用

### 1. 首次安装

```bash
# 给脚本添加执行权限
chmod +x claude_complete.sh

# 运行安装命令
./claude_complete.sh install
```

安装过程会：
- 检查并安装Node.js (v22)
- 安装Claude Code
- 配置跳过引导
- 创建设置文件
- 设置环境变量和别名
- 提示输入API Key

### 2. 启动Claude Code

```bash
# 方法1: 使用脚本启动
./claude_complete.sh start

# 方法2: 直接使用别名 (需要重新打开终端)
claude
```

### 3. 测试连接

```bash
./claude_complete.sh test
```

### 4. 查看帮助

```bash
./claude_complete.sh help
```

## 🔧 配置说明

### 环境变量

脚本会自动设置以下环境变量：

```bash
export ANTHROPIC_BASE_URL=你的中转站URL
export ANTHROPIC_API_KEY=你的API密钥
```

### 设置文件

自动创建的 `~/.claude/settings.json`:

```json
{
  "defaultModel": "anthropic/claude-sonnet-4",
  "fallbackModel": "anthropic/claude-sonnet-4",
  "autoAccept": false,
  "theme": "auto",
  "compactThreshold": 80,
  "compactPeriodDays": 7
}
```

### 别名

自动创建的别名：

```bash
alias claude="npx @anthropic-ai/claude-code --model anthropic/claude-sonnet-4"
```

## 🎯 使用示例

### 完整工作流程

```bash
# 1. 首次安装
./claude_complete.sh install

# 2. 重新加载环境变量
source ~/.zshrc  # 或 ~/.bashrc

# 3. 测试连接
./claude_complete.sh test

# 4. 启动使用
./claude_complete.sh start
```

### 快速启动

```bash
# 直接启动 (如果已安装)
./claude_complete.sh start

# 或者使用别名
claude
```

## 🔍 故障排除

### 常见问题

1. **环境变量未设置**
   ```bash
   ./claude_complete.sh install
   source ~/.zshrc
   ```

2. **API连接失败**
   ```bash
   ./claude_complete.sh test
   # 检查API Key是否正确
   ```

3. **Node.js版本过低**
   - 脚本会自动升级到Node.js v22

4. **权限问题**
   ```bash
   chmod +x claude_complete.sh
   ```

### 手动检查

```bash
# 检查Node.js版本
node -v

# 检查Claude Code安装
claude --version

# 检查环境变量
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_API_KEY

# 检查设置文件
cat ~/.claude/settings.json
```

## 📝 注意事项

1. **首次使用**: 必须先运行 `install` 命令
2. **API Key**: 请妥善保管您的API密钥
3. **网络连接**: 确保能够访问API服务器
4. **权限**: 脚本需要写入 `~/.zshrc` 或 `~/.bashrc` 的权限

## 🎉 完成！

安装完成后，您就可以愉快地使用Claude Code进行AI辅助编程了！

```bash
# 启动Claude Code
./claude_complete.sh start

# 或者直接使用
claude
``` 
