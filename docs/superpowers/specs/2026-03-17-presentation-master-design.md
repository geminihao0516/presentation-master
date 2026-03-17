# Presentation Master Skill — 設計規格

## 概述

建立一個 `presentation-master` 指揮層技能，整合 YouTube MCP、NotebookLM、anthropic-skills:pptx 與 NanoBanana PPT，提供從「任意輸入 → 專業簡報」的完整自動化流程。

**設計原則：預設零成本，可選升級。**

---

## 架構

```
使用者輸入（任一或多種組合）
│  YouTube URL / 主題關鍵字 / 文件路徑 / 網頁 URL
▼
┌──────────────────────────────────────────────────┐
│       presentation-master/SKILL.md                │
│       （指揮層 — 判斷輸入類型、調度子技能）         │
└────────────┬─────────────────────────────────────┘
             ▼
┌──────────────────────────────────────────────────┐
│  Phase 1: 內容擷取                                │
│  ├─ YouTube URL → mcp-youtube 下載字幕     [免費] │
│  │   → 字幕文字送入 Phase 2 作為來源              │
│  ├─ 網頁 URL   → 直接作為 NotebookLM 來源  [免費] │
│  ├─ 本地文件   → 上傳至 NotebookLM          [免費] │
│  └─ 主題關鍵字 → NotebookLM 深度網路研究    [免費] │
└────────────┬─────────────────────────────────────┘
             ▼
┌──────────────────────────────────────────────────┐
│  Phase 2: 研究與結構化（NotebookLM）              │
│  ├─ 建立 notebook + 匯入所有來源           [免費] │
│  ├─ 引用式問答提煉重點                     [免費] │
│  │   → 問 3-5 個關鍵問題，取得引用式回答          │
│  ├─ 生成 mind map → 作為簡報骨架           [免費] │
│  ├─ 生成 report → 作為內容底稿             [免費] │
│  └─ Claude 整理為 JSON 結構化簡報規劃             │
│     → slides_plan.json（標題、要點、講者備註）     │
└────────────┬─────────────────────────────────────┘
             ▼
┌──────────────────────────────────────────────────┐
│  Phase 3: 簡報生成（預設路線 A）                   │
│                                                   │
│  路線 A — 零成本（預設）:                          │
│  ├─ Claude 生成 HTML 投影片                [免費] │
│  │   → 720pt × 405pt (16:9) 每頁           │
│  │   → 支援 flexbox、漸層、圖示             │
│  ├─ anthropic-skills:pptx 轉換             [免費] │
│  │   → html2pptx.js 生成 .pptx                   │
│  │   → thumbnail.py 驗證排版                      │
│  └─ 輸出：.pptx + HTML 預覽                       │
│                                                   │
│  路線 B — AI 圖片升級（使用者選擇或提示後啟用）:    │
│  ├─ NanoBanana PPT（Gemini 圖片生成）     [需 API] │
│  │   → generate_ppt.py + 風格模板                 │
│  │   → 2K/4K PNG 圖片投影片                       │
│  └─ 輸出：PNG 圖片 + HTML 互動檢視器 + index.html  │
│     （NanoBanana 不生成 .pptx，輸出為圖片式簡報）   │
│                                                   │
│  路線 C — Gemini 手動提示詞（零成本替代方案）:      │
│  ├─ Claude 為每頁生成 Gemini 圖片提示詞           │
│  │   → 使用者可直接貼到 Gemini Pro 介面            │
│  │   → 包含風格、佈局、色彩指示                    │
│  └─ 輸出：提示詞清單 + 空白 .pptx 模板            │
└────────────┬─────────────────────────────────────┘
             ▼
┌──────────────────────────────────────────────────┐
│  Phase 4: 升級提示（每次完成後自動觸發）           │
│                                                   │
│  「簡報已生成完成！如果你想要更精美的 AI 圖片      │
│   投影片，有兩種方式：                             │
│                                                   │
│   1. 使用 NanoBanana 自動生成                     │
│      → 需要設定 GEMINI_API_KEY                    │
│      → 每頁約 $0.13 (2K) / $0.24 (4K)            │
│        （基於 Imagen 3 API 定價，截至 2026-03）    │
│        Gemini Pro 訂閱者可從 AI Studio 取得       │
│        免費 API key，但圖片生成額度需確認          │
│                                                   │
│   2. 手動在 Gemini Pro 生成                       │
│      → 我可以為每頁產生專屬提示詞                  │
│      → 你直接貼到 gemini.google.com 生成           │
│      → 完全免費（使用你的 Gemini Pro 額度）        │
│                                                   │
│   要試試嗎？輸入 1 或 2。」                        │
└──────────────────────────────────────────────────┘
```

---

## 安裝結構

```
~/.claude/skills/presentation-master/
├── SKILL.md              ← 主技能定義（Claude 讀取）
├── setup.sh              ← 一鍵安裝腳本
└── templates/
    └── gemini-prompt.md   ← Gemini 圖片提示詞模板

# NanoBanana 獨立安裝（可選）
~/.claude/skills/ppt-generator/
├── （由 install_as_skill.sh 安裝）
├── generate_ppt.py
├── styles/
├── prompts/
└── .env
```

**安裝步驟：**

```bash
# 1. Clone NanoBanana（安裝到技能目錄）
cd /tmp
git clone https://github.com/op7418/NanoBanana-PPT-Skills.git
cd NanoBanana-PPT-Skills

# 驗證 install_as_skill.sh 是否存在
if [ -f install_as_skill.sh ]; then
  bash install_as_skill.sh
else
  # 手動安裝 fallback
  mkdir -p ~/.claude/skills/ppt-generator
  cp -r generate_ppt.py styles/ prompts/ templates/ ~/.claude/skills/ppt-generator/
  cp SKILL.md ~/.claude/skills/ppt-generator/
fi

# 2. 建立 presentation-master skill
mkdir -p ~/.claude/skills/presentation-master/templates
# 寫入 SKILL.md（見下方完整內容）
# 寫入 gemini-prompt.md

# 3. 安裝 pptx 相關依賴（路線 A 必要）
npm install -g pptxgenjs sharp
npx playwright install chromium

# 4. 確認其他依賴
notebooklm login --check    # NotebookLM 認證
pip install google-genai pillow python-dotenv  # NanoBanana 依賴（可選，路線 B）
```

---

## 子技能依賴總覽

| 子技能 | 位置 | 費用 | 必要性 | 用途 |
|--------|------|------|--------|------|
| **mcp-youtube** | MCP 工具 | 免費 | 必要 | YouTube 字幕擷取 |
| **NotebookLM** | `~/.claude/skills/notebooklm/` | 免費 | 必要 | 研究、摘要、大綱、mind map |
| **anthropic-skills:pptx** | plugins/marketplaces/ | 免費 | 必要 | HTML → .pptx 轉換 |
| **NanoBanana PPT** | `~/.claude/skills/ppt-generator/` | Gemini API | 可選 | AI 圖片風格投影片 |
| **Gemini 提示詞模板** | presentation-master/templates/ | 免費 | 內建 | 手動 Gemini 生成提示 |

---

## SKILL.md 技能定義設計

### 觸發條件

- 使用者提到：「簡報」「PPT」「投影片」「presentation」「slide deck」「做簡報」「報告簡報」
- 使用者提供 YouTube URL 並要求做簡報
- 使用者提供主題並要求生成簡報
- 使用者說：「幫我做一份簡報」「把這個做成投影片」「準備報告」

### 必要輸入

至少提供一項：
1. **主題關鍵字**：用於 NotebookLM 網路研究
2. **YouTube URL**：擷取字幕作為來源
3. **網頁 URL**：作為 NotebookLM 來源
4. **本地文件**：PDF/DOCX/MD 上傳至 NotebookLM

可選輸入：
- 投影片數量（預設 10 頁）
- 目標受眾
- 風格偏好
- 語言（預設繁體中文）

### 預期輸出

**預設路線（零成本）：**
- `output/presentation.pptx` — 可編輯的 PowerPoint 檔案
- `output/presentation.html` — 瀏覽器預覽
- `output/slides_plan.json` — 結構化規劃（可重複使用）
- `output/research_notes.md` — 研究摘要與引用

**可選升級：**
- AI 圖片版 HTML 互動簡報（NanoBanana 路線）
- Gemini 提示詞清單（手動生成路線）

### 完成條件

1. 研究階段完成（至少 3 個引用式回答）
2. 簡報結構確認（slides_plan.json 生成）
3. .pptx 檔案生成且可開啟
4. 升級提示已顯示

---

## 技能調度機制

presentation-master 的 SKILL.md 是一份**完整的操作手冊**，直接內嵌所有子技能的
CLI 指令和腳本路徑。Claude 不需要「呼叫」其他 skill，而是按照 SKILL.md 中的步驟
依序執行 Bash 指令和工具呼叫。

具體來說：
- **mcp-youtube** → 透過 MCP 工具直接呼叫 `mcp__mcp-youtube__DownloadClosedCaptions`
- **NotebookLM** → 透過 Bash 執行 `notebooklm` CLI 指令
- **pptx 生成** → 透過 Bash 執行 `node html2pptx.js` 和 `python3 thumbnail.py`
- **NanoBanana** → 透過 Bash 執行 `python3 generate_ppt.py`

SKILL.md 不依賴其他 SKILL.md 的觸發機制，而是直接包含所有必要的指令。

---

## 執行流程詳細設計

### Step 1: 輸入解析

```
Claude 分析使用者輸入：
├─ 偵測 YouTube URL（含 youtube.com 或 youtu.be）→ youtube_sources[]
├─ 偵測 HTTP/HTTPS URL → web_sources[]
├─ 偵測本地檔案路徑 → file_sources[]
└─ 其餘文字 → topic_keywords
```

### Step 2: 內容擷取

YouTube 處理策略：**雙軌擷取**
- **主要路徑**：NotebookLM 原生支援 YouTube URL，直接用 `--url` 匯入
  （NotebookLM 會自動索引影片 transcript）
- **輔助路徑**：同時用 mcp-youtube 下載字幕作為預覽/備用
  （若 NotebookLM 的 YouTube 索引失敗，字幕文字可作為 `--text` 來源）

```
FOR EACH youtube_url IN youtube_sources:
  # 主要：直接送 NotebookLM（Step 3 匯入）
  # 輔助：同時擷取字幕備用
  transcript = mcp__mcp-youtube__DownloadClosedCaptions(youtube_url)
  → 儲存為 /tmp/presentation-master/captions/{video_id}.md
  → 字幕語言選擇優先順序：zh-TW > zh > en > 第一個可用語言

FOR EACH web_url IN web_sources:
  → 直接傳遞給 NotebookLM（Step 3）

FOR EACH file IN file_sources:
  → 直接傳遞給 NotebookLM（Step 3）
```

### Step 3: NotebookLM 研究

```bash
# 建立 notebook（儲存返回的 NOTEBOOK_ID）
NOTEBOOK_ID=$(notebooklm notebook create "簡報：{topic}" --json | python3 -c "import sys,json; print(json.load(sys.stdin)['notebook_id'])")

# 匯入所有來源
notebooklm source add $NOTEBOOK_ID --url "{web_url}"          # 網頁
notebooklm source add $NOTEBOOK_ID --url "{youtube_url}"      # YouTube（原生支援）
notebooklm source add $NOTEBOOK_ID --file "{file_path}"       # 文件

# 如果主題是關鍵字（無其他來源），啟動深度網路研究
notebooklm research start $NOTEBOOK_ID "{topic_keywords}"

# ⚠️ 等待所有來源處理完成（5-60 秒）
# 輪詢來源狀態直到全部就緒
notebooklm source list $NOTEBOOK_ID --json  # 檢查 status == "ready"

# 研究問答（3-5 個關鍵問題，取得引用式回答）
notebooklm chat $NOTEBOOK_ID "這份資料的核心論點是什麼？"
notebooklm chat $NOTEBOOK_ID "有哪些關鍵數據或證據支持？"
notebooklm chat $NOTEBOOK_ID "目標受眾最需要了解的 3-5 個重點？"
notebooklm chat $NOTEBOOK_ID "適合用什麼樣的視覺化方式呈現？"

# 生成結構化產物
MINDMAP=$(notebooklm generate mind-map $NOTEBOOK_ID --json)
# → 返回 JSON 格式的樹狀結構，包含 note_id
# → Claude 解析此 JSON 作為簡報骨架

REPORT=$(notebooklm generate report $NOTEBOOK_ID --format briefing_doc)
# → 返回 Markdown 格式的簡報底稿
```

### Step 4: 結構化規劃

Claude 根據 NotebookLM 的 mind map JSON + report + Q&A 回答，生成 `slides_plan.json`：

```json
{
  "title": "簡報標題",
  "subtitle": "副標題",
  "total_slides": 10,
  "language": "zh-TW",
  "slides": [
    {
      "page": 1,
      "type": "cover",
      "title": "主標題",
      "subtitle": "副標題",
      "notes": "講者備註"
    },
    {
      "page": 2,
      "type": "content",
      "title": "第一章節",
      "bullets": ["要點一", "要點二", "要點三"],
      "notes": "講者備註",
      "citation": "來源引用",
      "visual_hint": "建議用長條圖呈現數據比較"
    }
  ],
  "sources": [
    {"type": "youtube", "url": "...", "title": "..."},
    {"type": "web", "url": "...", "title": "..."}
  ]
}
```

### Step 5: 簡報生成（路線 A — 預設）

遵循 anthropic-skills:pptx 的 html2pptx 工作流程：

```
1. 為每頁投影片生成 HTML 檔案
   → 尺寸：720pt × 405pt (16:9)
   → 使用 flexbox 排版
   → 套用一致的色彩主題（CSS 變數）
   → 圖示使用 Unicode 符號或 SVG inline
     （不使用 react-icons，因為純 HTML 不支援 React 元件）
   → 若需要 SVG 圖示，先用 Sharp 光柵化為 PNG 再嵌入
   → 漸層背景用純色或 CSS linear-gradient 替代
     （pptx 不支援 CSS 漸層，需光柵化為背景圖片）

2. 撰寫 build.js 腳本呼叫 html2pptx()
   → 參考 ~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/pptx/html2pptx.md
   → 匯入 html2pptx 函式
   → 處理每個 HTML 檔案
   → 呼叫 pptx.writeFile('output/presentation.pptx')

3. 執行轉換
   node build.js

4. 驗證排版
   python3 thumbnail.py output/presentation.pptx
   → 生成縮圖網格，確認排版正確

5. 同時保留 HTML 版本作為瀏覽器預覽
   → 合併所有投影片 HTML 為 output/presentation.html
   → 加入鍵盤導航（← → 鍵翻頁）
```

### Step 6: 升級提示

簡報生成完成後，**自動顯示以下提示**：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
簡報已生成完成！

如果想要更精美的 AI 圖片投影片，你有兩個選擇：

【選項 1】NanoBanana 自動生成
  → 需要設定 GEMINI_API_KEY
  → 每頁約 $0.13 (2K) / $0.24 (4K)
  → 輸入「使用 NanoBanana 升級」即可

【選項 2】手動在 Gemini 生成
  → 我為每頁產生專屬提示詞
  → 你貼到 gemini.google.com 生成圖片
  → 完全免費（使用你的 Gemini Pro 額度）
  → 輸入「產生 Gemini 提示詞」即可
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Gemini 提示詞模板設計

當使用者選擇「路線 C — 手動 Gemini」時，為每頁投影片生成提示詞：

```markdown
## 第 {N} 頁：{slide_title}

請生成一張 16:9 的簡報投影片圖片。

**風格：** 漸變玻璃態設計（Gradient Glass Morphism）
- 深色漸層背景（深藍到深紫）
- 毛玻璃容器（半透明白色，圓角 16px）
- 微光效果和光暈裝飾

**內容佈局：**
- 標題：「{slide_title}」（粗體白色，左上角）
- 要點：
  {bullet_1}
  {bullet_2}
  {bullet_3}
- 右側放置相關的 3D 圖示或插圖

**技術規格：**
- 解析度：2560 × 1440 (2K)
- 格式：PNG
- 文字必須清晰可讀
- 中文字體，無英文
```

---

## 輸出目錄策略

```
{當前工作目錄}/output/presentation-{YYYY-MM-DD-HHmm}/
├── presentation.pptx        ← 可編輯簡報
├── presentation.html        ← 瀏覽器預覽
├── slides_plan.json         ← 結構化規劃（可重複使用）
├── research_notes.md        ← 研究摘要與引用
├── slides/                  ← 個別投影片 HTML
│   ├── slide-01.html
│   ├── slide-02.html
│   └── ...
├── thumbnails/              ← 排版驗證縮圖
│   └── grid.png
└── gemini-prompts.md        ← Gemini 提示詞（路線 C 時生成）
```

- 輸出目錄相對於使用者的當前工作目錄
- 每次生成加上時間戳，避免覆蓋舊輸出
- 完成時顯示輸出目錄的絕對路徑

---

## 錯誤處理

| 情境 | 處理方式 |
|------|---------|
| NotebookLM 未登入 | 提示執行 `notebooklm login`，等待使用者完成後繼續 |
| NotebookLM 來源處理中 | 輪詢 `source list --json` 每 10 秒檢查一次，超時 120 秒後警告 |
| YouTube 字幕不存在 | 跳過 mcp-youtube，改用 NotebookLM 原生 YouTube 索引 |
| YouTube 字幕語言不符 | 使用可用的第一個語言，在 research_notes.md 中標註 |
| NotebookLM 速率限制 | 等待 60 秒重試，最多 3 次，超過後輸出已有結果 |
| pptx 轉換失敗 | 降級為純 HTML 輸出，提示使用者可手動轉換 |
| html2pptx 依賴缺失 | 提示安裝 `npm install pptxgenjs playwright sharp` |
| NanoBanana 未安裝 | 升級提示中隱藏路線 B，只顯示路線 C |
| Gemini API key 未設定 | 升級提示中隱藏路線 B，只顯示路線 C |
| 來源處理失敗（單一） | 記錄錯誤，繼續處理其他來源，在 research_notes.md 中標註 |

---

## 與現有 UX 技能的搭配

presentation-master 可與 goodux-ux-skills 搭配使用：

| 搭配技能 | 搭配方式 |
|---------|---------|
| `wireframing` | 先用線框圖規劃投影片版面 |
| `ui-visual-design` | 選擇投影片的視覺風格和配色 |
| `information-architecture` | 規劃簡報的資訊層級和章節結構 |
| `user-interview` | 訪談結果整理成簡報 |
| `persona-creation` | 人物誌作為簡報來源 |

---

## 測試計畫

1. **純主題測試**：輸入「AI 的未來發展趨勢」→ 驗證完整流程
2. **YouTube 測試**：輸入一個 YouTube URL → 驗證字幕擷取 + 簡報生成
3. **混合測試**：主題 + YouTube URL + 網頁 URL → 驗證多來源整合
4. **升級提示測試**：驗證完成後的提示訊息正確顯示
5. **Gemini 提示詞測試**：驗證為每頁生成的提示詞品質
6. **降級測試**：模擬 NotebookLM 未登入 → 驗證錯誤處理
