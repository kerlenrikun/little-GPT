#!/bin/bash

# 模拟 GitHub Actions 环境变量
TYPE="minor"
CHANGESET_MESSAGE="Test enhancement workflow"
PR_NUMBER="277"
PR_AUTHOR="test-user"
PACKAGE_NAME="@promptx/cli"
FILENAME=".changeset/test-changeset.md"

echo "Testing changeset creation..."
echo "TYPE: $TYPE"
echo "MESSAGE: $CHANGESET_MESSAGE"
echo "PR: #$PR_NUMBER"
echo "AUTHOR: @$PR_AUTHOR"
echo "PACKAGE: $PACKAGE_NAME"
echo "---"

# 测试 heredoc 创建
cat > "$FILENAME" <<-CHANGESET_END
---
"${PACKAGE_NAME}": ${TYPE}
---

${CHANGESET_MESSAGE}

Contributed by @${PR_AUTHOR} via #${PR_NUMBER}
CHANGESET_END

if [ $? -eq 0 ]; then
    echo "✅ Changeset created successfully!"
    echo "Content:"
    cat "$FILENAME"
else
    echo "❌ Failed to create changeset"
fi

# 清理测试文件
rm -f "$FILENAME"