module.exports = {
  name: 'promptx_recall',
  description: `🔍 记忆检索系统

⚡ 需要经验/不确定/看到"上次" → 立即 recall

📌 从 mindmap 中选概念（激活角色时显示的图）：
• 找最相关的概念
• 可以多次 recall 不同概念
• 高相似度的都值得试试

💡 快速用法：
recall("当前角色", "mindmap中的概念")

---

## 🔍 详细说明（需要时查看）

### 何时检索
- 任务开始：需要相关经验
- 遇到问题：寻找类似解决方案
- 看到触发词："上次"、"之前"、"类似"

### 检索策略
- 使用 mindmap 中的精确概念
- 一次检索不够就多次扩散
- 关注高强度记忆（0.7以上）

### 记忆强度
- 0.9-1.0：核心记忆，优先使用
- 0.7-0.9：重要记忆，参考价值高
- 0.5-0.7：辅助记忆，补充信息`,
  inputSchema: {
    type: 'object',
    properties: {
      role: {
        type: 'string',
        description: '要检索记忆的角色ID，如：java-developer, product-manager, copywriter'
      },
      query: {
        type: 'string', 
        description: '检索线索（必填），必须使用角色激活时显示的mindmap中的精确概念。例如：如果激活角色时的mindmap中有"用户体验"，直接使用"用户体验"，禁止拆分成"用户"+"体验"'
      }
    },
    required: ['role', 'query']
  }
};