# Serena MCP Docker配置成功

## 问题原因
Docker挂载语法不完整，需要指定容器内路径

## 正确的挂载配置
```bash
-v /Users/sean/Management/ContradictionManagement/projects/PromptX:/workspaces/projects
```

## 激活项目
在容器内，项目位于 `/workspaces/projects`，使用此路径激活

## Serena优势
1. **语义化代码导航**：通过符号而非文件理解代码
2. **精确的符号查找**：find_symbol可以准确定位类、方法
3. **引用分析**：find_referencing_symbols找到所有引用
4. **项目记忆**：可以保存项目相关知识

## 对比传统工具
- Read → get_symbols_overview + find_symbol（更智能）
- Grep → search_for_pattern + find_symbol（更精确）
- Edit → replace_symbol_body（符号级别操作）