module.exports = {
  name: 'promptx_remember',
  description: `💾 记忆系统

⚡ 看到 error/失败/新知识 → 立即执行以下3步：

1️⃣ 快速判断类型：
   • 名词/概念 → type: "ATOMIC"  
   • 动词/关系 → type: "LINK"
   • 流程/模式 → type: "PATTERN"

2️⃣ 快速构造 schema（缩进表示层级）：
   大概念
     中概念  
       小概念

3️⃣ 快速评估 strength：
   • 核心/常用 → 0.9
   • 重要/有用 → 0.7
   • 背景/参考 → 0.5

📝 最简模板（复制修改）：
{
  role: "当前角色",
  engrams: [{
    content: "要记的内容",
    schema: "概念\\n  子概念", 
    strength: 0.8,
    type: "ATOMIC"
  }]
}

---

## 🔍 详细说明（需要时查看）

### 语义鸿沟触发
AI预训练知识与私有信息间的差异：
- 个人化：身份、偏好、项目细节
- 专业化：技术栈、配置、历史决策
- 上下文：对话中的特定概念关系

### 记忆编码原则
- **原子性**：一个Engram = 一个核心概念
- **层级性**：用缩进表达概念层次关系
- **批量性**：复杂信息分解为多个Engram

### 示例分解
"Sean开发PromptX框架" → 
[
  {content: "Sean是开发者", schema: "Sean\\n  人物\\n  创始人", strength: 0.9, type: "ATOMIC"},
  {content: "PromptX是AI框架", schema: "PromptX\\n  软件系统\\n  认知增强", strength: 0.9, type: "ATOMIC"},
  {content: "Sean开发PromptX", schema: "开发\\n  创造行为\\n  编程实现", strength: 0.95, type: "LINK"}
]`,
  inputSchema: {
    type: 'object',
    properties: {
      role: {
        type: 'string',
        description: '要保存记忆的角色ID，如：java-developer, product-manager, copywriter'
      },
      engrams: {
        type: 'array',
        description: 'Engram对象数组，支持批量记忆保存。每个对象包含content, schema, strength, type四个字段',
        items: {
          type: 'object',
          properties: {
            content: {
              type: 'string',
              description: '要保存的重要信息或经验'
            },
            schema: {
              type: 'string', 
              description: '知识关系图，用缩进文本格式表达这个知识在整个知识体系中的位置'
            },
            strength: {
              type: 'number',
              description: '记忆强度(0-1)，表示这个知识的重要程度，影响后续检索优先级',
              minimum: 0,
              maximum: 1,
              default: 0.8
            },
            type: {
              type: 'string',
              description: 'Engram类型，基于词性选择：ATOMIC（实体词性：名词、形容词、专有名词），LINK（关系词性：动词、介词、关系词），PATTERN（复合结构：短语、流程、模式）。ATOMIC和LINK的Cue必须是原子的单一词性',
              enum: ['ATOMIC', 'LINK', 'PATTERN'],
              default: 'ATOMIC'
            }
          },
          required: ['content', 'schema', 'strength', 'type']
        },
        minItems: 1
      }
    },
    required: ['role', 'engrams']
  }
};