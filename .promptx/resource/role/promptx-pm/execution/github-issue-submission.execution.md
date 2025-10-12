<execution>
  <constraint>
    ## GitHub Issue 提交的硬性约束
    - **标签规范文档位置**：`docs/label-guide.md` 必须在提交前查看
    - **标签存在性验证**：只能使用文档中定义的标签，不能臆造
    - **Issue 模板遵循**：必须包含问题描述、根因分析、影响范围、建议方案
    - **三方视角要求**：必须从人、AI、计算机三方分析问题影响
  </constraint>

  <rule>
    ## Issue 提交强制规则
    - **Step 0：必须先读取 `docs/label-guide.md`**，了解可用标签
    - **标签选择规则**：
      - Bug 修复 → `type: fix` + `priority: *` 
      - 新功能 → `type: feature` + `priority: *`
      - 文档 → `type: docs`
      - 重构 → `type: refactor`
    - **优先级判定**：
      - 核心功能缺陷 → `priority: critical`
      - 影响用户体验 → `priority: high`
      - 改进优化 → `priority: medium`
      - 边缘问题 → `priority: low`
    - **禁止使用不存在的标签**：如 `core-feature`、`design-deviation` 等
  </rule>

  <guideline>
    ## Issue 质量指南
    - **标题精炼**：一句话说清问题本质
    - **使用 emoji**：🔴 Critical、🟡 High、🟢 Medium、⚪ Low
    - **结构化内容**：使用 Markdown 格式，层次清晰
    - **提供复现路径**：具体步骤和测试代码
    - **量化影响**：明确影响范围和严重程度
  </guideline>

  <process>
    ## Issue 提交标准流程

    ### Step 1: 读取标签指南（强制）
    ```bash
    # 必须执行，了解可用标签
    cat docs/label-guide.md
    ```

    ### Step 2: 分析问题类型
    ```mermaid
    graph TD
        A[问题分析] --> B{问题类型}
        B -->|功能缺陷| C[type: fix]
        B -->|新需求| D[type: feature]
        B -->|性能问题| E[type: perf]
        B -->|文档缺失| F[type: docs]
        B -->|代码优化| G[type: refactor]
    ```

    ### Step 3: 评估优先级
    ```mermaid
    graph TD
        A[影响评估] --> B{影响程度}
        B -->|系统崩溃/核心功能失效| C[priority: critical]
        B -->|功能受损/体验问题| D[priority: high]
        B -->|改进建议/非紧急| E[priority: medium]
        B -->|边缘场景/低频问题| F[priority: low]
    ```

    ### Step 4: 编写 Issue 内容
    ```markdown
    # [emoji] 问题标题

    ## 问题描述
    简洁描述问题现象

    ## 根本原因分析
    ### 现象
    - 具体表现

    ### 原因
    - 深层原因分析

    ## 三方影响分析
    ### 人的视角
    - 用户体验影响

    ### AI的视角  
    - AI能力影响

    ### 计算机的视角
    - 系统性能影响

    ## 建议解决方案
    ### 方案1：[推荐]
    具体实现方式

    ### 方案2：
    备选方案

    ## 测试用例
    ```javascript
    // 复现代码或测试代码
    ```

    ## 相关代码
    - `path/to/file.js` - 相关函数
    ```

    ### Step 5: 使用正确标签创建
    ```bash
    # 使用 docs/label-guide.md 中的标签
    gh issue create \
      --title "[标题]" \
      --body-file issue.md \
      --label "type: fix,priority: high"  # 必须是文档中存在的标签
    ```
  </process>

  <criteria>
    ## Issue 质量标准
    - ✅ 已查看 `docs/label-guide.md`
    - ✅ 标签符合规范（全部来自文档）
    - ✅ 包含三方视角分析
    - ✅ 有明确的解决方案建议
    - ✅ 提供了测试或复现方法
    - ✅ 标注了相关代码位置
  </criteria>
</execution>