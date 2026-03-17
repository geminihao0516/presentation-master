---
name: presentation-master
description: >
  全方位簡報生成技能。接受任意輸入（主題、YouTube URL、網頁、文件），
  自動研究內容並生成專業簡報。三種模式自動適配：Lite（零依賴）、
  Standard（生成 .pptx）、Full（NotebookLM 深度研究）。
  內建 Gemini 提示詞生成器，Gemini Pro 用戶可免費獲得 AI 精美投影片。
  Use this skill when the user mentions: 簡報, PPT, 投影片, presentation,
  slide deck, 做簡報, 報告, slides, 幫我做簡報, 把這個做成投影片,
  準備報告, make a presentation, create slides.
  即使使用者只是說「幫我做一份簡報」或「summarize this into slides」也應觸發。
license: MIT
metadata:
  author: Hao
  version: 1.0.0
  category: productivity
  language: zh-TW
---

# Presentation Master

全方位簡報生成技能 — 從任意輸入到專業簡報的完整自動化流程。

## 核心原則

1. **零成本優先** — 預設不需要任何 API key 或付費服務
2. **自動適配** — 偵測環境中可用的工具，自動選擇最佳模式
3. **一句話使用** — 使用者只需說「幫我做簡報」就能開始
4. **漸進增強** — 從簡單到完整，每層都產出可用的結果

---

## Step 0: 環境偵測（自動執行，不需使用者操作）

在開始任何工作之前，先偵測可用工具：

```
CHECK_1: notebooklm login --check 2>/dev/null
  → 成功 = has_notebooklm
  → 失敗 = no_notebooklm

CHECK_2: which node && node -e "require('pptxgenjs')" 2>/dev/null
  → 成功 = has_pptx_tools
  → 失敗 = no_pptx_tools

CHECK_3: mcp__mcp-youtube__DownloadClosedCaptions 可用？
  → 檢查 MCP 工具列表
  → 可用 = has_youtube_mcp
  → 不可用 = no_youtube_mcp

CHECK_4: ls ~/.claude/skills/ppt-generator/generate_ppt.py 2>/dev/null
  → 存在 = has_nanobanana
  → 不存在 = no_nanobanana

CHECK_5: echo $GEMINI_API_KEY
  → 有值 = has_gemini_api
  → 空 = no_gemini_api
```

**模式選擇邏輯：**

```
IF has_notebooklm AND has_pptx_tools:
  → Full 模式（完整功能）

ELSE IF has_pptx_tools:
  → Standard 模式（無 NotebookLM 研究）

ELSE:
  → Lite 模式（零依賴）
```

**重要：不要詢問使用者選擇模式。** 自動偵測後直接告知：
> 「偵測到 [X] 模式環境。開始製作簡報。」

---

## Step 1: 收集輸入

詢問使用者（如果沒有在第一條訊息中提供）：

```
必要資訊（至少一項）：
├─ 主題關鍵字：「AI 未來趨勢」
├─ YouTube URL：https://youtube.com/watch?v=...
├─ 網頁 URL：https://example.com/article
└─ 本地文件路徑：/path/to/document.pdf

可選資訊（有預設值）：
├─ 投影片數量：預設 10 頁
├─ 目標受眾：預設「一般聽眾」
├─ 語言：預設繁體中文
└─ 視覺風格：預設「極簡白」
   可選風格（5 種）：
   1. 漸變玻璃態 — 科技/商務（深色漸層 + 毛玻璃）
   2. 極簡白 — 學術/正式（白底 + 單色強調）← 預設
   3. 暖色漸層 — 創意/行銷（橘紅漸層 + 白色卡片）
   4. 深色專業 — 技術/數據（深底 + 螢光重點色）
   5. 柔和粉彩 — 教育/輕鬆（粉彩色 + 圓角元素）
```

**不要問太多問題。** 只確認缺少的必要資訊。如果使用者說「幫我用 AI 主題做簡報」，
直接開始，不需要追問細節。

---

## Step 2: 內容擷取

根據輸入類型，擷取原始內容：

### YouTube URL 處理

```
IF has_youtube_mcp:
  transcript = mcp__mcp-youtube__DownloadClosedCaptions(url)
  → 語言優先順序：zh-TW > zh-Hant > zh > en > 第一個可用
  → 儲存為暫存文字

IF has_notebooklm (Full 模式):
  → YouTube URL 也直接送入 NotebookLM（原生支援 YouTube 索引）

IF 都沒有:
  → 請使用者手動複製 YouTube 影片描述或重點
```

### 網頁 URL 處理

```
IF has_notebooklm (Full 模式):
  → 直接送入 NotebookLM 作為來源

ELSE:
  → 使用 WebFetch 擷取網頁內容
  → Claude 直接分析
```

### 本地文件處理

```
IF has_notebooklm (Full 模式):
  → 上傳至 NotebookLM

ELSE:
  → 使用 Read 工具讀取文件內容
  → Claude 直接分析
```

---

## Step 3: 研究與分析

### Lite / Standard 模式

Claude 直接分析所有擷取的內容：
- 提煉核心論點（3-5 個）
- 整理支持數據和論據
- 規劃簡報結構和章節
- 決定每頁的重點和視覺化建議

### Full 模式（NotebookLM）

```bash
# 建立 notebook
NOTEBOOK_ID=$(notebooklm notebook create "簡報：{topic}" --json | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['notebook_id'])")

# 匯入所有來源
notebooklm source add $NOTEBOOK_ID --url "{url}"       # 網頁/YouTube
notebooklm source add $NOTEBOOK_ID --file "{path}"     # 本地文件
notebooklm source add $NOTEBOOK_ID --text "{title}" --content "{text}"  # 文字內容

# 等待來源處理完成（每 10 秒檢查，最多 120 秒）
# 輪詢 notebooklm source list $NOTEBOOK_ID --json 直到所有 status == "ready"

# 若只有主題關鍵字（無其他來源），啟動深度網路研究
notebooklm research start $NOTEBOOK_ID "{topic_keywords}"
# 等待研究完成

# 研究問答（取得引用式回答）
notebooklm chat $NOTEBOOK_ID "這份資料的核心論點是什麼？"
notebooklm chat $NOTEBOOK_ID "有哪些關鍵數據或證據支持？"
notebooklm chat $NOTEBOOK_ID "目標受眾最需要了解的重點？"
notebooklm chat $NOTEBOOK_ID "適合什麼視覺化方式呈現？"

# 生成結構化產物
notebooklm generate mind-map $NOTEBOOK_ID --json   # 結構骨架
notebooklm generate report $NOTEBOOK_ID --format briefing_doc  # 內容底稿
```

---

## Step 4: 結構化規劃

無論哪種模式，都生成 `slides_plan.json`：

```json
{
  "title": "簡報主標題",
  "subtitle": "副標題或日期",
  "total_slides": 10,
  "language": "zh-TW",
  "theme": {
    "primary_color": "2D3748",
    "accent_color": "4299E1",
    "background": "FFFFFF",
    "font": "Arial"
  },
  "slides": [
    {
      "page": 1,
      "type": "cover",
      "title": "主標題",
      "subtitle": "副標題",
      "notes": "開場白建議"
    },
    {
      "page": 2,
      "type": "section",
      "title": "第一章節標題",
      "notes": "章節轉場用"
    },
    {
      "page": 3,
      "type": "content",
      "title": "頁面標題",
      "bullets": ["要點一", "要點二", "要點三"],
      "notes": "講者備註：強調第二點",
      "visual_hint": "建議用長條圖",
      "citation": "資料來源（Full 模式才有）"
    },
    {
      "page": 10,
      "type": "closing",
      "title": "謝謝聆聽",
      "bullets": ["聯絡資訊", "Q&A"],
      "notes": "結語"
    }
  ]
}
```

**將 slides_plan.json 寫入輸出目錄。**

---

## Step 5: 簡報生成

### Lite 模式（零依賴）

生成純 HTML 簡報 + Gemini 提示詞：

```
1. 為每頁生成獨立的 HTML 檔案
   → 尺寸：960px × 540px (16:9)
   → 使用 web-safe 字體（Arial, Georgia）
   → 純 CSS 排版（flexbox）
   → 使用 Unicode 符號作為圖示（◆ ● ▶ ★ ✦ 等）
   → 不需要任何 npm 套件

2. 合併所有 HTML 為單一 presentation.html
   → 加入 JavaScript 鍵盤導航
   → ← → 鍵翻頁
   → ESC 全螢幕切換
   → 底部顯示頁碼

3. 同時生成 Gemini 提示詞（見 Step 6）
```

**Lite 模式的 HTML 模板：**

```html
<!DOCTYPE html>
<html lang="zh-TW">
<head>
<meta charset="UTF-8">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  width: 960px; height: 540px;
  font-family: Arial, "Microsoft JhengHei", sans-serif;
  display: flex; flex-direction: column;
  background: #FFFFFF;
  overflow: hidden;
}
.slide-header {
  padding: 40px 50px 20px;
}
.slide-header h1 {
  font-size: 32px; color: #2D3748;
  border-bottom: 3px solid #4299E1;
  padding-bottom: 12px;
}
.slide-body {
  flex: 1; padding: 20px 50px;
}
.slide-body ul {
  list-style: none; padding: 0;
}
.slide-body li {
  font-size: 20px; color: #4A5568;
  padding: 8px 0 8px 24px;
  position: relative;
}
.slide-body li::before {
  content: "◆"; color: #4299E1;
  position: absolute; left: 0;
}
.slide-footer {
  padding: 10px 50px;
  font-size: 12px; color: #A0AEC0;
  text-align: right;
}
</style>
</head>
<body>
  <div class="slide-header"><h1>{title}</h1></div>
  <div class="slide-body">
    <ul>
      <li>{bullet_1}</li>
      <li>{bullet_2}</li>
      <li>{bullet_3}</li>
    </ul>
  </div>
  <div class="slide-footer">{page} / {total}</div>
</body>
</html>
```

### Standard 模式（HTML → .pptx）

在 Lite 的基礎上，額外生成 .pptx：

```
1. 為每頁生成 HTML 檔案
   → 尺寸改為 720pt × 405pt（pptx 標準）
   → 文字必須用 <p>, <h1>-<h6>, <ul>, <ol> 包裹
   → 背景漸層需光柵化為 PNG（用 Sharp）
   → SVG 圖示需光柵化為 PNG

2. 使用 anthropic-skills:pptx 技能進行轉換
   → 觸發 pptx skill 處理 HTML → .pptx 轉換
   → pptx skill 會自動使用 html2pptx.js、pptxgenjs 等工具
   → 如果 pptx skill 不可用，改用以下 fallback：

   Fallback：直接用 pptxgenjs 建立 .pptx
   const pptxgen = require('pptxgenjs');
   const pptx = new pptxgen();
   pptx.layout = 'LAYOUT_16x9';
   // 為每頁加入文字和圖片
   // 用 slides_plan.json 的內容直接建構投影片
   await pptx.writeFile({ fileName: 'presentation.pptx' });

3. 執行轉換
   node build.js

4. 驗證排版（如有 LibreOffice + poppler + pptx skill）
   使用 pptx skill 的 thumbnail.py 驗證排版，或跳過驗證直接輸出
   python3 thumbnail.py \
     presentation.pptx thumbnails --cols 4
```

### Full 模式

在 Standard 的基礎上，內容來自 NotebookLM 的研究結果，
slides_plan.json 包含引用來源和更深入的內容。

---

## Step 6: Gemini 提示詞生成（所有模式都執行）

**這是核心功能之一**，為 Gemini Pro 用戶提供免費的 AI 精美投影片途徑。

為 slides_plan.json 中的每一頁生成專屬提示詞，寫入 `gemini-prompts.md`：

```markdown
# Gemini 投影片圖片生成提示詞

使用方式：將每個提示詞複製到 gemini.google.com，選擇「生成圖片」。
生成後下載圖片，插入到 .pptx 或 HTML 簡報中。

---

## 第 1 頁（封面）：{title}

請生成一張 16:9 的簡報封面投影片圖片。

風格：漸變玻璃態設計（Gradient Glass Morphism）
- 深色漸層背景（從 #1a1a2e 到 #16213e）
- 中央放置大型毛玻璃卡片（半透明白色，模糊效果，圓角 20px）
- 卡片上方有微光裝飾線條

文字內容（必須清晰可讀）：
- 主標題：「{title}」（粗體白色，48px，置中）
- 副標題：「{subtitle}」（淺灰色，24px，置中）

裝飾元素：
- 背景有柔和的光暈圓圈（半透明藍/紫色）
- 卡片邊緣有微光反射效果

技術規格：2560 × 1440 像素，PNG 格式，繁體中文

---

## 第 {N} 頁（內容）：{slide_title}

請生成一張 16:9 的簡報內容投影片圖片。

風格：漸變玻璃態設計
- 深色漸層背景（與封面一致）
- 左上角標題區域
- 內容區域使用毛玻璃容器

文字內容：
- 標題：「{slide_title}」（白色粗體，36px，左上角）
- 要點清單：
  ◆ {bullet_1}
  ◆ {bullet_2}
  ◆ {bullet_3}
（每個要點 20px，淺灰白色，行距 1.8）

視覺建議：{visual_hint}
- 右側或下方放置相關的 3D 圖示或資訊圖表
- 圖示風格：玻璃質感、半透明、帶光暈

技術規格：2560 × 1440 像素，PNG 格式，繁體中文
```

**提示詞品質要求：**
- 每頁的提示詞必須保持風格一致（相同的背景、色調、字體描述）
- 文字內容必須明確寫出，不留佔位符
- 包含具體的像素尺寸和顏色 hex 碼
- 指明繁體中文（或使用者指定的語言）

---

## Step 7: 輸出結果與升級提示

### 輸出目錄結構

```
{工作目錄}/output/presentation-{YYYYMMDD-HHmm}/
├── presentation.html        ← 瀏覽器預覽（所有模式）
├── presentation.pptx        ← 可編輯簡報（Standard/Full）
├── slides_plan.json         ← 結構化規劃
├── gemini-prompts.md        ← Gemini 提示詞（所有模式）
├── research_notes.md        ← 研究筆記（Full 模式）
├── slides/                  ← 個別投影片 HTML
│   ├── slide-01.html
│   └── ...
└── build.js                 ← 轉換腳本（Standard/Full）
```

### 完成訊息

完成後顯示：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
簡報生成完成！（{mode} 模式，共 {N} 頁）

輸出位置：{absolute_path}

已生成的檔案：
  ✓ presentation.html — 在瀏覽器中開啟即可預覽
  ✓ presentation.pptx — 用 PowerPoint / Google Slides 編輯（如有）
  ✓ gemini-prompts.md — Gemini 圖片提示詞（見下方說明）
  ✓ slides_plan.json  — 可重複使用的結構規劃

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 想要更精美的 AI 圖片投影片嗎？

  你可以用 gemini-prompts.md 裡的提示詞，
  直接貼到 gemini.google.com 生成精美圖片，
  然後插入到 .pptx 中。完全免費（用你的 Gemini Pro 額度）。

  → 輸入「幫我生成 Gemini 圖片提示詞」重新生成
  → 輸入「換個風格」更換視覺風格

  也可以使用 NanoBanana PPT 自動生成（需要 Gemini API key）：
  → 輸入「使用 NanoBanana 升級」
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 錯誤處理

| 情境 | 處理方式 |
|------|---------|
| NotebookLM 未登入 | 降級為 Standard/Lite 模式，提示可用 `notebooklm login` 啟用 Full 模式 |
| NotebookLM 來源處理中 | 輪詢 `source list --json` 每 10 秒，超時 120 秒後用已有結果繼續 |
| YouTube 字幕不存在 | 若有 NotebookLM 用原生索引；否則請使用者提供影片摘要 |
| YouTube 字幕語言不符 | 用第一個可用語言，在 research_notes.md 標註 |
| NotebookLM 速率限制 | 等待 60 秒重試，最多 3 次 |
| pptx 轉換失敗 | 降級為純 HTML，提示安裝依賴 |
| html2pptx 依賴缺失 | 降級為 Lite 模式，提示 `npm install pptxgenjs playwright sharp` |
| NanoBanana 未安裝 | 升級提示中隱藏 NanoBanana 選項 |
| 來源處理失敗 | 跳過失敗來源，繼續處理其他，記錄在 research_notes.md |
| WebFetch 失敗 | 請使用者手動貼上網頁內容 |

---

## NanoBanana 升級路線（使用者觸發時才執行）

當使用者輸入「使用 NanoBanana 升級」或類似指令時：

```bash
# 確認 NanoBanana 已安裝
ls ~/.claude/skills/ppt-generator/generate_ppt.py

# 確認 Gemini API key
echo $GEMINI_API_KEY

# 執行生成
cd ~/.claude/skills/ppt-generator
python3 generate_ppt.py \
  --plan {slides_plan.json 路徑} \
  --style styles/gradient-glass.md \
  --output {輸出目錄} \
  --resolution 2K

# NanoBanana 輸出為 PNG 圖片 + index.html
# 不輸出 .pptx（圖片式簡報）
```

---

## 與其他技能的搭配

| 技能 | 搭配方式 |
|------|---------|
| `wireframing` | 先規劃投影片版面，再生成簡報 |
| `ui-visual-design` | 選擇投影片的視覺風格和配色 |
| `information-architecture` | 規劃簡報的資訊層級和章節結構 |
| `notebooklm` | 深度研究、引用式問答、生成 mind map |
| `anthropic-skills:pptx` | HTML → .pptx 轉換 |
| `ppt-generator-pro` | NanoBanana AI 圖片生成 |
