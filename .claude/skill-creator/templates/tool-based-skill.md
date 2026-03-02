# 工具型 Skill 模板

> 适用场景：需要执行脚本、调用命令行工具、操作文件系统的skill
> 例如：自动部署、数据库备份、日志分析、自动化测试

---

## 模板内容（复制以下内容到你的 skill.md 中，替换 {{占位符}}）

```markdown
# {{Skill名称}}

## 触发条件（When to use）

当用户的意图匹配以下任何一种情况时，激活此skill：

- 用户说"{{触发关键词1}}"
- 用户说"{{触发关键词2}}"
- 用户说"{{触发关键词3}}"

## 能力说明（What it does）

### 能做的事：
- {{能力1}}
- {{能力2}}

### 不能做的事：
- {{限制1}}
- {{限制2}}

## 前置条件（Prerequisites）

在使用此skill之前，确保以下条件满足：

- [ ] {{依赖工具1}} 已安装（检查命令：`{{检查命令1}}`）
- [ ] {{依赖工具2}} 已安装（检查命令：`{{检查命令2}}`）
- [ ] {{所需权限描述}}
- [ ] {{所需配置描述}}

## 工作流程（How it works）

### 步骤1：环境检查
执行以下检查确保环境就绪：
```bash
# 检查必要工具是否存在
which {{工具名}} || echo "错误：{{工具名}} 未安装"
```

### 步骤2：{{步骤名称}}
```bash
# {{描述这个命令做什么}}
{{实际的bash命令}}
```

### 步骤3：{{步骤名称}}
```bash
# {{描述这个命令做什么}}
{{实际的bash命令}}
```

### 步骤4：结果验证
```bash
# 验证操作是否成功
{{验证命令}}
```

## 工具脚本说明（Tools）

### tools/{{脚本名}}.sh
- 用途：{{脚本做什么}}
- 输入参数：{{参数说明}}
- 输出：{{输出说明}}
- 调用方式：`bash tools/{{脚本名}}.sh {{参数}}`

## 错误处理（Error handling）

| 错误场景 | 错误信息 | 处理方式 |
|----------|---------|---------|
| {{场景1}} | {{错误信息1}} | {{处理方式1}} |
| {{场景2}} | {{错误信息2}} | {{处理方式2}} |
| {{场景3}} | {{错误信息3}} | {{处理方式3}} |

## 安全注意事项（Security）

- {{安全提示1}}
- {{安全提示2}}
- 涉及破坏性操作时，必须先向用户确认

## 回滚方案（Rollback）

如果操作失败，按以下步骤回滚：
1. {{回滚步骤1}}
2. {{回滚步骤2}}
```

---

## 使用此模板的文件结构

```
你的skill名/
├── skill.md              ← 主文件，包含上面的模板内容
├── README.md             ← 使用说明
├── tools/
│   ├── main-script.sh    ← 主脚本
│   ├── helper.sh         ← 辅助脚本（如果需要）
│   └── rollback.sh       ← 回滚脚本（建议有）
└── knowledge/
    └── reference.md      ← 参考资料（可选）
```

---

## 填写示例：一个"项目初始化"skill

```markdown
# Project Init - 项目初始化工具

## 触发条件（When to use）

- 用户说"初始化一个新项目"
- 用户说"创建项目模板"
- 用户说"新建一个XX项目"

## 能力说明（What it does）

### 能做的事：
- 创建标准化的项目目录结构
- 初始化 git 仓库和 .gitignore
- 生成 package.json 和基础配置文件
- 安装常用依赖

### 不能做的事：
- 不负责部署和上线
- 不创建数据库

## 前置条件（Prerequisites）

- [ ] Node.js 18+ 已安装（检查命令：`node --version`）
- [ ] Git 已安装（检查命令：`git --version`）
- [ ] npm 已安装（检查命令：`npm --version`）

## 工作流程（How it works）

### 步骤1：环境检查
```bash
node --version && git --version && npm --version
```

### 步骤2：创建项目目录
```bash
mkdir -p $PROJECT_NAME/{src,tests,docs,config}
cd $PROJECT_NAME
```

### 步骤3：初始化项目
```bash
npm init -y
git init
```

### 步骤4：生成配置文件
使用 tools/init.sh 脚本生成所有配置文件。

### 步骤5：安装依赖
```bash
npm install
```

## 工具脚本说明（Tools）

### tools/init.sh
- 用途：生成项目配置文件（.gitignore, tsconfig.json 等）
- 输入参数：$1 = 项目类型（react/node/fullstack）
- 输出：在当前目录生成配置文件
- 调用方式：`bash tools/init.sh react`

## 错误处理（Error handling）

| 错误场景 | 错误信息 | 处理方式 |
|----------|---------|---------|
| Node.js未安装 | command not found: node | 提示用户安装Node.js |
| 目录已存在 | directory already exists | 询问用户是否覆盖 |
| npm安装失败 | npm ERR! | 检查网络连接，重试 |

## 安全注意事项（Security）

- 不自动覆盖已有文件
- 涉及删除操作前必须确认

## 回滚方案（Rollback）

1. 删除新创建的项目目录：`rm -rf $PROJECT_NAME`
2. 如果是在已有目录中操作，使用 git 恢复：`git checkout .`
```
