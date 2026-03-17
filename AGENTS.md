# Presentation Master — Agent 設定

## Gemini CLI 支援

此技能同時支援 Claude Code 和 Gemini CLI。

### Gemini CLI 工具對應

| Claude Code 工具 | Gemini CLI 對應 |
|-----------------|----------------|
| Read | read_file |
| Write | write_file |
| Edit | edit_file |
| Bash | run_command |
| Glob | glob |
| Grep | grep |
| WebFetch | fetch_url |

### Gemini CLI 安裝

```bash
# 安裝技能
git clone https://github.com/geminihao0516/presentation-master.git
cd presentation-master
bash install.sh

# 在 Gemini CLI 中使用
gemini "幫我做一份簡報"
```
