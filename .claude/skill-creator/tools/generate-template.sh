#!/usr/bin/env bash
# ============================================================
# Skill 模板生成器
# 用途：快速生成一个新skill的文件结构骨架
# 用法：bash generate-template.sh <skill名称> <类型>
#   类型可选：basic | tool | knowledge
# 示例：bash generate-template.sh my-helper basic
# ============================================================

set -euo pipefail

# 参数检查
if [ $# -lt 2 ]; then
    echo "用法: $0 <skill名称> <类型>"
    echo ""
    echo "类型说明:"
    echo "  basic     - 基础型（只有skill.md）"
    echo "  tool      - 工具型（包含tools/目录）"
    echo "  knowledge - 知识型（包含knowledge/目录）"
    echo ""
    echo "示例:"
    echo "  $0 code-reviewer basic"
    echo "  $0 auto-deploy tool"
    echo "  $0 react-expert knowledge"
    exit 1
fi

SKILL_NAME="$1"
SKILL_TYPE="$2"
TARGET_DIR="$HOME/.claude/skills/$SKILL_NAME"

# 检查命名规范
if ! echo "$SKILL_NAME" | grep -qE '^[a-z][a-z0-9-]*$'; then
    echo "错误：skill名称不规范。"
    echo "规则：只能使用英文小写字母、数字和连字符。"
    echo "示例：my-skill, code-reviewer, api-helper"
    exit 1
fi

# 检查类型是否合法
if [[ "$SKILL_TYPE" != "basic" && "$SKILL_TYPE" != "tool" && "$SKILL_TYPE" != "knowledge" ]]; then
    echo "错误：未知的类型 '$SKILL_TYPE'"
    echo "可选类型：basic, tool, knowledge"
    exit 1
fi

# 检查是否已存在
if [ -d "$TARGET_DIR" ]; then
    echo "警告：目录已存在: $TARGET_DIR"
    read -p "是否覆盖？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消。"
        exit 0
    fi
fi

echo "正在创建 $SKILL_TYPE 类型的 skill: $SKILL_NAME ..."

# 创建基础目录
mkdir -p "$TARGET_DIR"

# ==========================================
# 生成 skill.md
# ==========================================
cat > "$TARGET_DIR/skill.md" << 'SKILLEOF'
# {{SKILL_NAME}}

## 触发条件（When to use）

当用户的意图匹配以下任何一种情况时，激活此skill：

- 用户说"TODO: 添加触发关键词1"
- 用户说"TODO: 添加触发关键词2"
- 用户说"TODO: 添加触发关键词3"

## 能力说明（What it does）

### 能做的事：
- TODO: 列出能力1
- TODO: 列出能力2

### 不能做的事：
- TODO: 列出限制1
- TODO: 列出限制2

## 工作流程（How it works）

### 步骤1：TODO: 步骤名称
TODO: 详细描述这一步做什么

### 步骤2：TODO: 步骤名称
TODO: 详细描述这一步做什么

### 步骤3：TODO: 步骤名称
TODO: 详细描述这一步做什么

## 输出格式（Output format）

TODO: 定义输出的格式和模板

## 注意事项（Important notes）

- TODO: 添加注意事项

## 错误处理（Error handling）

- 如果 TODO: 异常情况1，则 TODO: 处理方式1
- 如果 TODO: 异常情况2，则 TODO: 处理方式2
SKILLEOF

# 替换 skill 名称
sed -i "s/{{SKILL_NAME}}/$SKILL_NAME/g" "$TARGET_DIR/skill.md"

# ==========================================
# 生成 README.md
# ==========================================
cat > "$TARGET_DIR/README.md" << READMEEOF
# $SKILL_NAME

## 简介

TODO: 一句话描述这个skill做什么

## 安装

将此文件夹复制到 \`~/.claude/skills/\` 目录下：

\`\`\`
cp -r $SKILL_NAME ~/.claude/skills/
\`\`\`

## 使用方法

TODO: 说明如何触发和使用

## 示例

TODO: 提供一个使用示例
READMEEOF

# ==========================================
# 根据类型创建额外目录和文件
# ==========================================

if [ "$SKILL_TYPE" = "tool" ]; then
    mkdir -p "$TARGET_DIR/tools"

    cat > "$TARGET_DIR/tools/main.sh" << 'TOOLEOF'
#!/usr/bin/env bash
# ============================================================
# TODO: 脚本名称和描述
# 用途：TODO: 描述此脚本的用途
# 用法：bash main.sh <参数>
# ============================================================

set -euo pipefail

# 参数检查
if [ $# -lt 1 ]; then
    echo "用法: $0 <参数>"
    exit 1
fi

# TODO: 在这里编写你的脚本逻辑

echo "完成。"
TOOLEOF

    chmod +x "$TARGET_DIR/tools/main.sh"

    # 在 skill.md 中追加工具说明
    cat >> "$TARGET_DIR/skill.md" << 'APPENDEOF'

## 工具脚本说明（Tools）

### tools/main.sh
- 用途：TODO: 描述脚本用途
- 输入参数：TODO: 参数说明
- 输出：TODO: 输出说明
- 调用方式：`bash tools/main.sh <参数>`
APPENDEOF
fi

if [ "$SKILL_TYPE" = "knowledge" ]; then
    mkdir -p "$TARGET_DIR/knowledge"

    cat > "$TARGET_DIR/knowledge/core.md" << 'KNOWLEDGEEOF'
# 核心知识

TODO: 在此编写核心概念和知识内容

## 基本概念

## 关键原理

## 常用规则
KNOWLEDGEEOF

    cat > "$TARGET_DIR/knowledge/examples.md" << 'EXAMPLEEOF'
# 示例库

TODO: 在此添加代码示例和使用案例

## 示例1：基础用法

## 示例2：进阶用法

## 示例3：最佳实践
EXAMPLEEOF

    # 在 skill.md 中追加知识说明
    cat >> "$TARGET_DIR/skill.md" << 'APPENDEOF'

## 知识文件说明

| 文件 | 内容 | 何时加载 |
|------|------|---------|
| `knowledge/core.md` | 核心概念和知识 | 用户问基础问题时 |
| `knowledge/examples.md` | 示例库 | 用户需要示例时 |
APPENDEOF
fi

# ==========================================
# 输出结果
# ==========================================
echo ""
echo "创建完成！"
echo ""
echo "文件结构："
find "$TARGET_DIR" -type f | sort | while read -r file; do
    echo "  ${file#$TARGET_DIR/}"
done
echo ""
echo "安装位置: $TARGET_DIR"
echo ""
echo "下一步："
echo "  1. 编辑 $TARGET_DIR/skill.md，替换所有 TODO 项"
echo "  2. 编辑 $TARGET_DIR/README.md，补充使用说明"
if [ "$SKILL_TYPE" = "tool" ]; then
    echo "  3. 编辑 $TARGET_DIR/tools/main.sh，编写脚本逻辑"
fi
if [ "$SKILL_TYPE" = "knowledge" ]; then
    echo "  3. 编辑 knowledge/ 下的文件，填充知识内容"
fi
echo "  最后：运行 validate-skill.sh 验证质量"
