#!/usr/bin/env bash
# ============================================================
# Skill 验证脚本
# 用途：检查一个skill文件夹是否符合创建标准
# 用法：bash validate-skill.sh <skill文件夹路径>
# ============================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计分
TOTAL_SCORE=0
MAX_SCORE=100
ERRORS=0
WARNINGS=0

# 打印函数
pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; ((ERRORS++)); }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARNINGS++)); }
info() { echo -e "       $1"; }

# 参数检查
if [ $# -lt 1 ]; then
    echo "用法: $0 <skill文件夹路径>"
    echo "示例: $0 ~/.claude/skills/my-skill"
    exit 1
fi

SKILL_DIR="$1"

echo "============================================"
echo "  Skill 质量验证报告"
echo "  检查目标: $SKILL_DIR"
echo "============================================"
echo ""

# ==========================================
# 第一关：文件结构检查（20分）
# ==========================================
echo "--- 第一关：文件结构检查 ---"

# 检查目录是否存在
if [ -d "$SKILL_DIR" ]; then
    pass "Skill目录存在"
    TOTAL_SCORE=$((TOTAL_SCORE + 5))
else
    fail "Skill目录不存在: $SKILL_DIR"
    echo ""
    echo "验证失败：目标目录不存在。"
    exit 1
fi

# 检查 skill.md 是否存在
if [ -f "$SKILL_DIR/skill.md" ]; then
    pass "skill.md 文件存在"
    TOTAL_SCORE=$((TOTAL_SCORE + 10))
else
    fail "skill.md 文件不存在（这是唯一必需的文件！）"
fi

# 检查 skill.md 是否为空
if [ -f "$SKILL_DIR/skill.md" ] && [ -s "$SKILL_DIR/skill.md" ]; then
    pass "skill.md 不为空"
    TOTAL_SCORE=$((TOTAL_SCORE + 5))
else
    fail "skill.md 为空"
fi

# 检查文件夹命名
DIRNAME=$(basename "$SKILL_DIR")
if echo "$DIRNAME" | grep -qE '^[a-z][a-z0-9-]*$'; then
    pass "文件夹命名规范 ($DIRNAME)"
else
    warn "文件夹命名不规范: $DIRNAME（建议使用英文小写+连字符）"
fi

# 检查是否有敏感文件
SENSITIVE_FILES=$(find "$SKILL_DIR" -name "*.env" -o -name "*.key" -o -name "*.pem" -o -name "*secret*" -o -name "*password*" 2>/dev/null || true)
if [ -z "$SENSITIVE_FILES" ]; then
    pass "未发现敏感文件"
else
    fail "发现可能的敏感文件: $SENSITIVE_FILES"
fi

echo ""

# ==========================================
# 第二关：skill.md 内容检查（50分）
# ==========================================
echo "--- 第二关：skill.md 内容检查 ---"

if [ -f "$SKILL_DIR/skill.md" ]; then
    CONTENT=$(cat "$SKILL_DIR/skill.md")

    # 检查触发条件
    if echo "$CONTENT" | grep -qiE '触发条件|when to use|trigger'; then
        pass "包含触发条件章节"
        TOTAL_SCORE=$((TOTAL_SCORE + 10))
    else
        fail "缺少触发条件章节"
    fi

    # 检查能力说明
    if echo "$CONTENT" | grep -qiE '能力说明|what it does|能做|capabilities'; then
        pass "包含能力说明章节"
        TOTAL_SCORE=$((TOTAL_SCORE + 10))
    else
        fail "缺少能力说明章节"
    fi

    # 检查工作流程
    if echo "$CONTENT" | grep -qiE '工作流程|how it works|步骤|workflow'; then
        pass "包含工作流程章节"
        TOTAL_SCORE=$((TOTAL_SCORE + 15))
    else
        fail "缺少工作流程章节"
    fi

    # 检查错误处理
    if echo "$CONTENT" | grep -qiE '错误处理|error handling|异常|出错'; then
        pass "包含错误处理章节"
        TOTAL_SCORE=$((TOTAL_SCORE + 10))
    else
        warn "缺少错误处理章节（建议添加）"
    fi

    # 检查输出格式
    if echo "$CONTENT" | grep -qiE '输出格式|output format|输出模板'; then
        pass "包含输出格式定义"
        TOTAL_SCORE=$((TOTAL_SCORE + 5))
    else
        warn "缺少输出格式定义（建议添加）"
    fi
fi

echo ""

# ==========================================
# 第三关：工具脚本检查（15分）
# ==========================================
echo "--- 第三关：工具脚本检查 ---"

if [ -d "$SKILL_DIR/tools" ]; then
    info "发现 tools/ 目录"

    # 检查脚本文件
    SCRIPTS=$(find "$SKILL_DIR/tools" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) 2>/dev/null || true)

    if [ -n "$SCRIPTS" ]; then
        for script in $SCRIPTS; do
            SCRIPT_NAME=$(basename "$script")

            # 检查执行权限
            if [ -x "$script" ]; then
                pass "$SCRIPT_NAME 有执行权限"
                TOTAL_SCORE=$((TOTAL_SCORE + 5))
            else
                warn "$SCRIPT_NAME 缺少执行权限（运行 chmod +x $script）"
            fi

            # 检查 shell 脚本的安全性
            if [[ "$script" == *.sh ]]; then
                if grep -q 'set -e' "$script" 2>/dev/null; then
                    pass "$SCRIPT_NAME 有错误退出设置 (set -e)"
                    TOTAL_SCORE=$((TOTAL_SCORE + 5))
                else
                    warn "$SCRIPT_NAME 建议添加 set -euo pipefail"
                fi

                if grep -q 'rm -rf /' "$script" 2>/dev/null; then
                    fail "$SCRIPT_NAME 包含危险命令 (rm -rf /)"
                else
                    pass "$SCRIPT_NAME 未发现危险命令"
                    TOTAL_SCORE=$((TOTAL_SCORE + 5))
                fi
            fi
        done
    else
        info "tools/ 目录为空（如果不需要脚本可以删除此目录）"
    fi
else
    info "无 tools/ 目录（基础型skill不需要）"
    TOTAL_SCORE=$((TOTAL_SCORE + 15))
fi

echo ""

# ==========================================
# 第四关：知识文件检查（15分）
# ==========================================
echo "--- 第四关：知识文件检查 ---"

if [ -d "$SKILL_DIR/knowledge" ]; then
    info "发现 knowledge/ 目录"

    KNOWLEDGE_FILES=$(find "$SKILL_DIR/knowledge" -name "*.md" 2>/dev/null || true)
    if [ -n "$KNOWLEDGE_FILES" ]; then
        FILE_COUNT=$(echo "$KNOWLEDGE_FILES" | wc -l)
        pass "包含 $FILE_COUNT 个知识文件"
        TOTAL_SCORE=$((TOTAL_SCORE + 10))

        for kfile in $KNOWLEDGE_FILES; do
            KNAME=$(basename "$kfile")
            if [ -s "$kfile" ]; then
                pass "$KNAME 不为空"
            else
                warn "$KNAME 为空文件"
            fi
        done
        TOTAL_SCORE=$((TOTAL_SCORE + 5))
    else
        warn "knowledge/ 目录为空"
    fi
else
    info "无 knowledge/ 目录（基础型skill不需要）"
    TOTAL_SCORE=$((TOTAL_SCORE + 15))
fi

echo ""

# ==========================================
# 汇总报告
# ==========================================
echo "============================================"
echo "  验证结果汇总"
echo "============================================"
echo ""
echo "  得分: $TOTAL_SCORE / $MAX_SCORE"
echo "  错误: $ERRORS 个"
echo "  警告: $WARNINGS 个"
echo ""

if [ $TOTAL_SCORE -ge 80 ]; then
    echo -e "  ${GREEN}评级: 优秀 - Skill质量合格${NC}"
elif [ $TOTAL_SCORE -ge 60 ]; then
    echo -e "  ${YELLOW}评级: 及格 - 建议修复警告项${NC}"
else
    echo -e "  ${RED}评级: 不合格 - 请修复错误项后重新验证${NC}"
fi

echo ""
echo "============================================"

exit $ERRORS
