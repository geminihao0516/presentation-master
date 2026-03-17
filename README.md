# Presentation Master

> 全方位簡報生成技能 — 一句話從任意內容生成專業簡報

支援 [Claude Code](https://claude.ai/code) 和 [Gemini CLI](https://github.com/google-gemini/gemini-cli)。

## 特色

- **零成本** — 預設不需要任何 API key 或付費服務
- **一句話使用** — 說「幫我做簡報」就能開始
- **三種模式自動適配** — 依據你的環境自動選擇最佳模式
- **Gemini Pro 友善** — 內建 AI 圖片提示詞，免費生成精美投影片
- **多來源輸入** — YouTube、網頁、文件、主題關鍵字，通通可以
- **跨平台** — macOS、Linux、Windows (WSL/Git Bash)

## 三種模式

| 模式 | 需要安裝 | 輸出 | 適合 |
|------|---------|------|------|
| **Lite** | 無（零依賴） | HTML 簡報 + Gemini 提示詞 | 學生、快速報告 |
| **Standard** | Node.js + npm 套件 | .pptx + HTML + Gemini 提示詞 | 需要可編輯檔案 |
| **Full** | + NotebookLM | 上述 + 深度研究筆記 | 學術研究、專業報告 |

**不需要手動選擇模式** — 安裝腳本和技能都會自動偵測環境。

## 快速開始

### 安裝

```bash
# 下載
# 方法一：Git clone
git clone https://github.com/geminihao0516/presentation-master.git
cd presentation-master

# 方法二：直接下載 zip（不需要 git）
# 從 GitHub 頁面點擊 Code > Download ZIP，解壓縮後進入目錄

# 安裝（自動偵測環境）
bash install.sh
```

安裝完成後，在 Claude Code 中直接使用：

```
「幫我用 AI 未來趨勢做一份 10 頁簡報」
```

### 安裝選項

```bash
# 只安裝核心（零依賴，最快）
bash install.sh --lite

# 安裝核心 + .pptx 支援
bash install.sh --standard

# 安裝全部功能
bash install.sh --full
```

## 使用範例

### 基本用法

```
「幫我做一份關於氣候變遷的簡報」
```

### 從 YouTube 影片生成

```
「用這個影片做簡報：https://youtube.com/watch?v=xxxxx」
```

### 多來源混合

```
「用這些資料做簡報：
 - https://youtube.com/watch?v=xxxxx
 - https://example.com/article
 - 主題：量子計算的商業應用
 15 頁，目標受眾是高階主管」
```

### 生成 Gemini 圖片提示詞

```
「幫我產生 Gemini 提示詞，風格用漸變玻璃態」
```

### 使用 NanoBanana 升級

```
「使用 NanoBanana 升級」
```

## Gemini Pro 用戶專屬

如果你是 Gemini Pro 訂閱者，可以：

1. 簡報生成後，開啟 `gemini-prompts.md`
2. 複製每頁的提示詞到 [gemini.google.com](https://gemini.google.com)
3. 選擇「生成圖片」
4. 下載圖片，插入到 .pptx 中

**完全免費**，使用你的 Gemini Pro 額度。

## 內建 5 種視覺風格

1. **漸變玻璃態** — 科技、商務、產品發表
2. **極簡白** — 學術報告、課堂簡報
3. **暖色漸層** — 創意提案、行銷簡報
4. **深色專業** — 技術分享、數據分析
5. **柔和粉彩** — 教育、輕鬆主題

## 可選整合

| 整合 | 用途 | 安裝方式 |
|------|------|---------|
| [NotebookLM](https://notebooklm.google.com) | 深度研究、引用來源 | `pip install notebooklm-py` |
| [NanoBanana PPT](https://github.com/op7418/NanoBanana-PPT-Skills) | AI 圖片投影片（需 Gemini API） | `bash install.sh --full` |
| YouTube MCP | 影片字幕擷取 | Claude Code MCP 設定 |
| [goodux-ux-skills](https://github.com/zz41354899/goodux-skills) | UX 設計技能搭配 | `npx goodux-ux-skills` |

## 輸出檔案

```
output/presentation-{日期時間}/
├── presentation.html        ← 瀏覽器預覽（所有模式）
├── presentation.pptx        ← PowerPoint 可編輯（Standard/Full）
├── slides_plan.json         ← 結構規劃（可重複使用）
├── gemini-prompts.md        ← Gemini 圖片提示詞
├── research_notes.md        ← 研究筆記（Full 模式）
└── slides/                  ← 個別投影片 HTML
```

## 系統需求

### 最低需求（Lite 模式）

- Claude Code 或 Gemini CLI
- 就這樣，不需要其他東西

### Standard 模式額外需求

- Node.js 16+
- npm 套件：`pptxgenjs`, `playwright`, `sharp`
- （可選）LibreOffice — 排版驗證

### Full 模式額外需求

- Python 3.8+
- notebooklm-py
- （可選）NanoBanana PPT + Gemini API key

## 跨平台支援

| 平台 | 狀態 | 備註 |
|------|------|------|
| macOS | 完整支援 | Homebrew 安裝依賴 |
| Ubuntu/Debian | 完整支援 | apt 安裝依賴 |
| Fedora/RHEL | 完整支援 | dnf 安裝依賴 |
| Arch Linux | 完整支援 | pacman 安裝依賴 |
| Windows (WSL) | 完整支援 | 透過 WSL2 |
| Windows (Git Bash) | 基本支援 | Lite 模式 |

## 授權

MIT License

## 致謝

- [NanoBanana-PPT-Skills](https://github.com/op7418/NanoBanana-PPT-Skills) — AI 圖片簡報生成
- [NotebookLM](https://notebooklm.google.com) — 免費 AI 研究引擎
- [anthropic-skills:pptx](https://github.com/anthropics/agent-skills) — HTML to PowerPoint 轉換
- [goodux-ux-skills](https://github.com/zz41354899/goodux-skills) — UX 設計技能
