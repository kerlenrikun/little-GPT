const BasePouchCommand = require('../BasePouchCommand')
const fs = require('fs-extra')
const path = require('path')
const { COMMANDS } = require('../../../../constants')
const { getGlobalResourceManager } = require('../../resource')
const DPMLContentParser = require('../../dpml/DPMLContentParser')
const SemanticRenderer = require('../../dpml/SemanticRenderer')
const ProjectManager = require('../../../utils/ProjectManager')
const { getGlobalProjectManager } = require('../../../utils/ProjectManager')
const { getGlobalServerEnvironment } = require('../../../utils/ServerEnvironment')
const logger = require('../../../utils/logger')

/**
 * 角色激活锦囊命令
 * 负责分析角色文件，提取需要学习的thought、execution和knowledge
 */
class ActionCommand extends BasePouchCommand {
  constructor () {
    super()
    // 使用全局单例 ResourceManager
    this.resourceManager = getGlobalResourceManager()
    this.dpmlParser = new DPMLContentParser()
    this.semanticRenderer = new SemanticRenderer()
    this.projectManager = getGlobalProjectManager()
  }

  getPurpose () {
    return '激活特定AI角色，分析并生成具体的思维模式、行为模式和知识学习计划'
  }

  async getContent (args) {
    // 智能提示，不阻断服务

    const [roleId] = args

    if (!roleId) {
      return `❌ 请指定要激活的角色ID

🔍 使用方法：
通过 MCP PromptX 工具的 action 功能激活角色

💡 查看可用角色：
使用 MCP PromptX 工具的 welcome 功能`
    }

    try {
      logger.debug(`[ActionCommand] 开始激活角色: ${roleId}`)
      
      // 0. 初始化 ResourceManager（确保引用解析正常工作）
      if (!this.resourceManager.initialized) {
        await this.resourceManager.initializeWithNewArchitecture()
      }
      
      // 1. 获取角色信息
      const roleInfo = await this.getRoleInfo(roleId)
      logger.debug(`[ActionCommand] getRoleInfo结果:`, roleInfo)
      
      if (!roleInfo) {
        logger.warn(`[ActionCommand] 角色 "${roleId}" 不存在！`)
        return `❌ 角色 "${roleId}" 不存在！

🔍 可能的原因：
- 角色尚未注册到系统中
- 刚刚创建的新角色需要刷新注册表

💡 解决方案：
1. **查看可用角色**：使用 welcome 功能查看所有可用角色
2. **确认角色ID**：使用正确的角色ID重试

`
      }

      // 2. 分析角色文件，提取依赖
      const dependencies = await this.analyzeRoleDependencies(roleInfo)

      // 3. 生成学习计划并直接加载所有内容
      return await this.generateLearningPlan(roleInfo, dependencies)
    } catch (error) {
      logger.error('Action command error:', error)
      return `❌ 激活角色 "${roleId}" 时发生错误。

🔍 可能的原因：
- 角色文件不存在或格式错误
- 新创建的角色尚未注册到系统
- 权限不足
- 系统资源问题

💡 解决方案：
1. **查看可用角色**：使用 welcome 功能查看角色列表
2. **确认角色名称**：使用正确的角色ID重试

📋 **错误详情**：${error.message}`
    }
  }

  /**
   * 获取角色信息（直接从ResourceManager）
   */
  async getRoleInfo (roleId) {
    logger.debug(`[ActionCommand] getRoleInfo调用，角色ID: ${roleId}`)
    
    // 直接使用ResourceManager获取角色信息，移除对WelcomeCommand的依赖
    logger.debug(`[ActionCommand] 直接从ResourceManager获取角色信息`)
    
    const roles = this.resourceManager.registryData.getResourcesByProtocol('role')
    logger.debug(`[ActionCommand] 找到${roles.length}个角色`)
    
    const role = roles.find(r => r.id === roleId)
    logger.debug(`[ActionCommand] 查找角色${roleId}结果:`, role ? '找到' : '未找到')
    
    if (!role) {
      return null
    }
    
    const result = {
      id: role.id,
      name: role.name,
      description: role.description,
      file: role.reference
    }
    
    logger.debug(`[ActionCommand] 返回角色信息:`, result)
    return result
  }

  /**
   * 分析角色文件，提取完整的角色语义（@引用 + 直接内容）
   */
  async analyzeRoleDependencies (roleInfo) {
    try {
      // 处理文件路径，将@package://和@project://前缀替换为实际路径
      let filePath = roleInfo.file
      if (filePath.startsWith('@package://')) {
        const PackageProtocol = require('../../resource/protocols/PackageProtocol')
        const packageProtocol = new PackageProtocol()
        const relativePath = filePath.replace('@package://', '')
        filePath = await packageProtocol.resolvePath(relativePath)
      } else if (filePath.startsWith('@project://')) {
        // 🎯 使用ProjectProtocol确保HTTP模式下正确的路径映射
        const projectProtocol = this.resourceManager.protocols.get('project')
        const relativePath = filePath.replace('@project://', '')
        filePath = await projectProtocol.resolvePath(relativePath)
      } else if (filePath.startsWith('@user://')) {
        // 处理User级资源路径
        const userProtocol = this.resourceManager.protocols.get('user')
        const relativePath = filePath.replace('@user://', '')
        filePath = await userProtocol.resolvePath(relativePath)
      }

      // 读取角色文件内容
      const roleContent = await fs.readFile(filePath, 'utf-8')
      
      // 使用DPMLContentParser解析完整的角色语义
      const roleSemantics = this.dpmlParser.parseRoleDocument(roleContent)
      
      // 提取@引用依赖（保持兼容性）
      // 注意：对于包含语义内容的角色，引用已在语义渲染中处理，无需重复加载
      const thoughts = new Set()
      const executions = new Set()
      
      // 从所有标签中提取thought和execution引用
      // 但排除已在语义内容中处理的引用
      Object.values(roleSemantics).forEach(tagSemantics => {
        if (tagSemantics && tagSemantics.references) {
          tagSemantics.references.forEach(ref => {
            // 跳过已在语义内容中处理的引用
            if (tagSemantics.fullSemantics) {
              // 如果标签有完整语义内容，其引用将在语义渲染中处理，无需独立加载
              return
            }
            
            if (ref.protocol === 'thought') {
              thoughts.add(ref.resource)
            } else if (ref.protocol === 'execution') {
              executions.add(ref.resource)
            }
          })
        }
      })

      return {
        // 保持原有结构（兼容性）
        thoughts,
        executions,
        knowledge: [roleInfo.id],
        
        // 新增：完整的角色语义结构
        roleSemantics: {
          personality: roleSemantics.personality || null,
          principle: roleSemantics.principle || null,
          knowledge: roleSemantics.knowledge || null
        }
      }
    } catch (error) {
      logger.error('Error analyzing role dependencies:', error)
      // 如果分析失败，返回基础结构
      return {
        thoughts: [],
        executions: [],
        knowledge: [roleInfo.id],
        roleSemantics: {
          personality: null,
          principle: null,
          knowledge: null
        }
      }
    }
  }

  /**
   * 生成学习指引（基于分析出的依赖）
   */
  generateLearningGuide (roleInfo, dependencies) {
    let guide = `🎬 **角色激活计划：${roleInfo.name}**

📋 **角色概述**
${roleInfo.description}

`

    // 思维模式部分
    if (dependencies.thoughts.length > 0) {
      guide += `## 🧠 第一步：学习思维模式
掌握角色所需的核心思考技能

`
      dependencies.thoughts.forEach((thought, index) => {
        guide += `### ${index + 1}. ${thought}
\`\`\`bash
promptx learn thought://${thought}
\`\`\`

`
      })
    }

    // 行为模式部分
    if (dependencies.executions.length > 0) {
      guide += `## ⚖️ 第二步：学习行为模式
掌握角色所需的核心执行技能

`
      dependencies.executions.forEach((execution, index) => {
        guide += `### ${index + 1}. ${execution}
\`\`\`bash
promptx learn execution://${execution}
\`\`\`

`
      })
    }

    // 知识部分
    guide += `## 📚 第三步：学习专业知识
获取角色的领域知识体系

`
    dependencies.knowledge.forEach((knowledge, index) => {
      guide += `### ${index + 1}. ${knowledge} 领域知识
\`\`\`bash
promptx learn knowledge://${knowledge}
\`\`\`

`
    })

    // 编排学习
    guide += `## 🎪 第四步：学习编排方式
理解如何组合使用已学的技能

\`\`\`bash
promptx learn personality://${roleInfo.id}
\`\`\`

\`\`\`bash
promptx learn principle://${roleInfo.id}
\`\`\`

## ✅ 角色激活确认

完成学习后，请确认角色激活：

1. **思维确认**：🧠 "我已掌握所需的思考技能！"
2. **行为确认**：⚖️ "我已掌握所需的执行技能！"  
3. **知识确认**：📚 "我已具备领域专业知识！"
4. **编排确认**：🎪 "我已理解技能的组合使用方式！"

💡 **设计理念**：基于 DPML 基础协议组合，通过thought和execution的灵活编排实现角色能力。`

    return guide
  }

  /**
   * 加载学习内容（复用LearnCommand逻辑）
   */
  async loadLearnContent (resourceUrl) {
    try {
      const result = await this.resourceManager.resolve(resourceUrl)
      
      if (!result.success) {
        return `❌ 无法加载 ${resourceUrl}: ${result.error.message}\n\n`
      }

      // 解析协议信息
      const urlMatch = resourceUrl.match(/^(@[!?]?)?([a-zA-Z][a-zA-Z0-9_-]*):\/\/(.+)$/)
      if (!urlMatch) {
        return `❌ 无效的资源URL格式: ${resourceUrl}\n\n`
      }
      
      const [, loadingSemantic, protocol, resourceId] = urlMatch

      const protocolLabels = {
        thought: '🧠 思维模式',
        execution: '⚡ 执行模式',
        memory: '💾 记忆模式',
        personality: '👤 角色人格',
        principle: '⚖️ 行为原则',
        knowledge: '📚 专业知识'
      }

      const label = protocolLabels[protocol] || `📄 ${protocol}`

      return `## ✅ ${label}：${resourceId}
${result.content}
---
`
    } catch (error) {
      return `❌ 加载 ${resourceUrl} 时发生错误: ${error.message}\n\n`
    }
  }

  /**
   * 生成学习计划并直接加载所有内容（包含完整的角色语义）
   */
  async generateLearningPlan (roleInfo, dependencies) {
    const { thoughts, executions, roleSemantics } = dependencies
    const { id: roleId } = roleInfo

    let content = `🎭 **角色激活完成：\`${roleId}\` (${roleInfo.name})** - 所有技能已自动加载\n`

    // 自动执行 prime 激活语义网络（放在最前面）
    content += await this.executePrime(roleId)

    // 加载思维模式技能（仅包含独立的thought引用）
    if (thoughts.size > 0) {
      content += `# 🧠 思维模式技能 (${thoughts.size}个)\n`
      
      // 加载引用的思维资源
      for (const thought of Array.from(thoughts)) {
        content += await this.loadLearnContent(`thought://${thought}`)
      }
    }

    // 添加角色人格特征（支持@引用占位符语义渲染）
    if (roleSemantics.personality && roleSemantics.personality.fullSemantics) {
      content += `# 👤 角色人格特征\n`
      content += `## ✅ 👤 人格特征：${roleId}\n`
      const personalityContent = await this.semanticRenderer.renderSemanticContent(
        roleSemantics.personality, 
        this.resourceManager
      )
      content += `${personalityContent}\n`
      content += `---\n`
    }

    // 加载执行技能（仅包含独立的execution引用）
    if (executions.size > 0) {
      content += `# ⚡ 执行技能 (${executions.size}个)\n`
      
      // 加载引用的执行资源
      for (const execution of Array.from(executions)) {
        content += await this.loadLearnContent(`execution://${execution}`)
      }
    }

    // 添加角色行为原则（支持@引用占位符语义渲染）
    if (roleSemantics.principle && roleSemantics.principle.fullSemantics) {
      content += `# ⚖️ 角色行为原则\n`
      content += `## ✅ ⚖️ 行为原则：${roleId}\n`
      const principleContent = await this.semanticRenderer.renderSemanticContent(
        roleSemantics.principle, 
        this.resourceManager
      )
      content += `${principleContent}\n`
      content += `---\n`
    }

    // 添加语义渲染的知识体系（支持@引用占位符）
    if (roleSemantics.knowledge && roleSemantics.knowledge.fullSemantics) {
      content += `# 📚 专业知识体系\n`
      content += `## ✅ 📚 知识体系：${roleId}-knowledge\n`
      const knowledgeContent = await this.semanticRenderer.renderSemanticContent(
        roleSemantics.knowledge, 
        this.resourceManager
      )
      content += `${knowledgeContent}\n`
      content += `---\n`
    }

    // 激活总结
    content += `# 🎯 角色激活总结\n`
    content += `✅ **\`${roleId}\` (${roleInfo.name}) 角色已完全激活！**\n`
    content += `📋 **已获得能力**：\n`
    if (thoughts.size > 0) content += `- 🧠 思维模式：${Array.from(thoughts).join(', ')}\n`
    if (executions.size > 0) content += `- ⚡ 执行技能：${Array.from(executions).join(', ')}\n`
    
    // 显示角色核心组件
    const roleComponents = []
    if (roleSemantics.personality?.fullSemantics) roleComponents.push('👤 人格特征')
    if (roleSemantics.principle?.fullSemantics) roleComponents.push('⚖️ 行为原则')
    if (roleSemantics.knowledge?.fullSemantics) roleComponents.push('📚 专业知识')
    if (roleComponents.length > 0) {
      content += `- 🎭 角色组件：${roleComponents.join(', ')}\n`
    }
    
    content += `💡 **现在可以立即开始以 \`${roleId}\` (${roleInfo.name}) 身份提供专业服务！**\n`

    return content
  }

  /**
   * 自动执行 prime 激活语义网络
   */
  async executePrime (roleId) {
    try {
      // 导入 CognitionManager
      const { CognitionManager } = require('../../cognition/CognitionManager')
      const cognitionManager = new CognitionManager(this.resourceManager)
      
      // 获取角色的认知实例并激活语义网络
      const cognition = await cognitionManager.getCognition(roleId)
      const semanticMermaid = await cognition.prime()
      
      if (!semanticMermaid || semanticMermaid.trim() === '') {
        // 语义网络为空，静默处理
        return ''
      }
      
      let output = `---
## 🧠 语义网络激活（记忆检索索引）
\`\`\`mermaid
${semanticMermaid}
\`\`\`
📌 **重要说明**：上述 mindmap 是你的记忆检索索引！
- 🔍 **用途**：使用 recall 工具时，必须从这个 mindmap 中选择精确概念作为检索线索
- 💡 **示例**：如果 mindmap 中有"用户体验"，recall 时直接使用"用户体验"，不要拆分成"用户"+"体验"
- ⚡ **技巧**：概念越精确，检索效果越好。优先使用 mindmap 中的叶子节点概念
`
      
      // 尝试激活程序性记忆
      try {
        const proceduralPatterns = await cognition.primeProcedural()
        if (proceduralPatterns) {
          output += '\n' + proceduralPatterns
        }
      } catch (error) {
        // 程序性记忆激活失败不影响主流程
        logger.debug('Procedural prime failed:', error)
      }
      
      return output
    } catch (error) {
      logger.error('Auto prime error:', error)
      // Prime失败不影响角色激活，静默处理
      return ''
    }
  }

  getPATEOAS (args) {
    const [roleId] = args

    if (!roleId) {
      return {
        currentState: 'action_awaiting_role',
        availableTransitions: ['welcome'],
        nextActions: [
                  {
          name: '查看可用角色',
          description: '返回角色发现页面',
          method: 'MCP PromptX welcome 工具',
          priority: 'high'
        }
        ],
        metadata: {
          message: '需要指定角色ID'
        }
      }
    }

    return {
      currentState: 'role_activated',
      availableTransitions: ['welcome', 'remember', 'learn', 'recall'],
      nextActions: [
        {
          name: '开始专业服务',
          description: '角色已激活，语义网络已预热，可直接提供专业服务',
          method: '开始对话',
          priority: 'high'
        },
        {
          name: '返回角色选择',
          description: '选择其他角色',
          method: 'MCP PromptX welcome 工具',
          priority: 'medium'
        },
        {
          name: '记忆新知识',
          description: '内化更多专业知识',
          method: 'MCP PromptX remember 工具',
          priority: 'low'
        },
        {
          name: '学习新资源',
          description: '学习相关专业资源',
          method: 'MCP PromptX learn 工具',
          priority: 'low'
        }
      ],
      metadata: {
        targetRole: roleId,
        roleActivated: true,
        memoryRecalled: true,
        architecture: 'DPML协议组合',
        approach: '直接激活-自动记忆-立即可用',
        systemVersion: '锦囊串联状态机 v2.1',
        designPhilosophy: 'AI use CLI get prompt for AI - 一键专家化，自动记忆'
      }
    }
  }

  /**
   * 重写execute方法以添加多项目状态检查
   */
  async execute (args = []) {
    // 从执行上下文获取MCP信息
    const mcpId = this.detectMcpId()
    const ideType = await this.detectIdeType()
    
    // 获取多项目状态提示
    const projectPrompt = await this.projectManager.generateTopLevelProjectPrompt('action', mcpId, ideType)
    
    const purpose = this.getPurpose()
    const content = await this.getContent(args)
    const pateoas = await this.getPATEOAS(args)

    return this.formatOutputWithProjectCheck(purpose, content, pateoas, projectPrompt)
  }

  /**
   * 检测MCP进程ID
   */
  detectMcpId() {
    const serverEnv = getGlobalServerEnvironment()
    if (serverEnv.isInitialized()) {
      return serverEnv.getMcpId()
    }
    return ProjectManager.generateMcpId()
  }

  /**
   * 检测IDE类型 - 从配置文件读取，移除环境变量检测
   */
  async detectIdeType() {
    const mcpId = this.detectMcpId()
    return await this.projectManager.getIdeType(mcpId)
  }
  
  /**
   * 格式化带有项目检查的输出
   */
  formatOutputWithProjectCheck(purpose, content, pateoas, projectPrompt) {
    // 先调用父类的 formatOutput 获取标准格式
    const baseOutput = super.formatOutput(purpose, content, pateoas)
    
    // 如果是 JSON 格式，添加 projectPrompt
    if (this.outputFormat === 'json') {
      return {
        ...baseOutput,
        projectPrompt
      }
    }
    
    // 人类可读格式：在基础输出前加上项目提示
    return {
      ...baseOutput,
      toString() {
        const baseString = baseOutput.toString()
        // 在基础输出前插入项目提示
        return `${projectPrompt}

${baseString}`
      }
    }
  }
}

module.exports = ActionCommand
