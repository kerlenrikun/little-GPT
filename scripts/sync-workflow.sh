#!/bin/bash

# 通用workflow同步脚本
# 用法: ./sync-workflow.sh [文件路径] [提交信息]
# 示例: ./sync-workflow.sh .github/workflows/deploy.yml "feat: 优化deploy工作流"

set -e

echo "🔄 通用Workflow同步脚本"
echo "================================"

# 参数处理
WORKFLOW_FILE=${1:-".github/workflows/start.yml"}
COMMIT_MESSAGE=${2:-"chore: 同步workflow更新"}

# 检查文件是否存在
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ 文件不存在: $WORKFLOW_FILE"
    exit 1
fi

echo "📦 同步文件: $WORKFLOW_FILE"
echo "💬 提交信息: $COMMIT_MESSAGE"
echo ""

# 保存当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 当前分支: $CURRENT_BRANCH"

# 添加文件到暂存区
git add "$WORKFLOW_FILE"
echo "✅ 已添加文件到暂存区"

# 保存文件内容
TEMP_FILE="/tmp/$(basename $WORKFLOW_FILE).sync"
cp "$WORKFLOW_FILE" "$TEMP_FILE"
echo "💾 已保存文件内容到临时文件"

# 同步函数
sync_to_branch() {
    local BRANCH=$1
    echo ""
    echo "🔄 同步到 $BRANCH 分支..."
    
    # 切换到目标分支
    git checkout $BRANCH
    
    # 拉取最新
    echo "📥 拉取最新代码..."
    git pull origin $BRANCH --no-edit || true
    
    # 复制文件
    cp "$TEMP_FILE" "$WORKFLOW_FILE"
    
    # 检查是否有变化
    if git diff --quiet "$WORKFLOW_FILE"; then
        echo "✅ $BRANCH - 文件已经是最新版本"
    else
        # 提交修改
        git add "$WORKFLOW_FILE"
        git commit -m "$COMMIT_MESSAGE

从 $CURRENT_BRANCH 分支同步" || echo "No changes to commit"
        
        # 推送
        git push origin $BRANCH
        echo "✅ $BRANCH - 同步成功"
    fi
}

# 确认操作
echo ""
echo "⚠️  即将同步到以下分支："
echo "  - develop"
echo "  - main"
echo ""
read -p "确认继续？(y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 操作已取消"
    # 切回原分支
    git checkout "$CURRENT_BRANCH" 2>/dev/null || true
    exit 1
fi

# 执行同步
sync_to_branch "develop"
sync_to_branch "main"

# 切回原分支
echo ""
echo "🔙 切回原分支: $CURRENT_BRANCH"
git checkout "$CURRENT_BRANCH"

# 清理临时文件
rm -f "$TEMP_FILE"

echo ""
echo "✨ 同步完成！"
echo ""
echo "📝 已同步的内容："
echo "  📄 文件: $WORKFLOW_FILE"
echo "  🌿 分支: develop, main"
echo "  💬 提交: $COMMIT_MESSAGE"
echo ""
echo "🚀 现在可以继续你的工作了！"