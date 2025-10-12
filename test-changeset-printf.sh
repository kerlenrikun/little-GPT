#!/bin/bash
# 测试新的 printf 方式生成 changeset

TYPE="minor"
CHANGESET_MESSAGE="Test enhancement workflow"
PR_NUMBER="277"
PR_AUTHOR="test-user"
PACKAGE_NAME="@promptx/cli"
FILENAME=".changeset/test-printf.md"

echo "Testing changeset creation with printf..."
echo "TYPE: $TYPE"
echo "MESSAGE: $CHANGESET_MESSAGE"
echo "---"

# 使用 printf 创建 changeset 文件
printf '%s\n' \
  '---' \
  "\"${PACKAGE_NAME}\": ${TYPE}" \
  '---' \
  '' \
  "${CHANGESET_MESSAGE}" \
  '' \
  "Contributed by @${PR_AUTHOR} via #${PR_NUMBER}" \
  > "$FILENAME"

echo "Created changeset file: $FILENAME"
echo "Content:"
cat "$FILENAME"

# 验证文件格式
echo ""
echo "Validating changeset format..."
if grep -q "^---$" "$FILENAME" && grep -q "\"${PACKAGE_NAME}\": ${TYPE}" "$FILENAME"; then
  echo "✅ Changeset format is valid!"
else
  echo "❌ Changeset format is invalid!"
  exit 1
fi

# 清理测试文件
rm "$FILENAME"
echo "Test completed successfully!"