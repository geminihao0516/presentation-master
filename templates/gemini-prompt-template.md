# Gemini 投影片圖片生成提示詞模板

此模板供 presentation-master 技能使用，為每頁投影片生成 Gemini 提示詞。

## 使用方式

1. 將提示詞複製到 gemini.google.com
2. 選擇「生成圖片」
3. 下載生成的圖片
4. 插入到 .pptx 或 HTML 簡報中

---

## 封面頁模板

```
請生成一張 16:9 的簡報封面投影片圖片。

風格：{style_name}

背景設計：
- {background_description}

主要內容：
- 主標題：「{title}」（{title_font_size}px，{title_color}，{title_position}）
- 副標題：「{subtitle}」（{subtitle_font_size}px，{subtitle_color}）

裝飾元素：
- {decoration_1}
- {decoration_2}

技術規格：
- 解析度：2560 × 1440 像素
- 格式：PNG
- 文字必須清晰可讀
- 使用{language}
```

## 內容頁模板

```
請生成一張 16:9 的簡報內容投影片圖片。

風格：{style_name}（與前頁保持一致的視覺風格）

背景：{background_description}

文字內容：
- 標題：「{slide_title}」（{title_font_size}px，{title_color}，左上角）
- 要點清單：
  ◆ {bullet_1}
  ◆ {bullet_2}
  ◆ {bullet_3}
（每個要點 {bullet_font_size}px，{bullet_color}，行距 1.8）

視覺元素：
- {visual_hint}

技術規格：
- 解析度：2560 × 1440 像素
- 格式：PNG
- 文字必須清晰可讀
- 使用{language}
```

## 章節頁模板

```
請生成一張 16:9 的簡報章節分隔投影片圖片。

風格：{style_name}

背景：{background_description}，比內容頁略深

主要內容：
- 章節標題：「{section_title}」（{title_font_size}px，{title_color}，置中）
- 章節編號或裝飾線條

裝飾：大型幾何裝飾或相關圖示

技術規格：2560 × 1440 像素，PNG 格式，{language}
```

## 結尾頁模板

```
請生成一張 16:9 的簡報結尾投影片圖片。

風格：{style_name}

背景：{background_description}

主要內容：
- 標題：「{closing_title}」（{title_font_size}px，{title_color}，置中）
- 副標題或聯絡資訊：「{contact_info}」（{subtitle_font_size}px）

裝飾：與封面呼應的視覺元素

技術規格：2560 × 1440 像素，PNG 格式，{language}
```

---

## 可用風格

### 1. 漸變玻璃態（Gradient Glass Morphism）
適合：科技、商務、產品發表
```
背景：深色漸層（從 #1a1a2e 到 #16213e）
容器：毛玻璃卡片（半透明白色，backdrop-blur，圓角 20px）
裝飾：柔和光暈圓圈（半透明藍/紫色）、微光邊緣
字體顏色：白色標題、淺灰內容
```

### 2. 極簡白（Minimal White）
適合：學術報告、課堂簡報、正式場合
```
背景：純白或極淺灰（#FAFAFA）
裝飾：細線條分隔、幾何色塊點綴
重點色：單一強調色（如 #2563EB 或 #059669）
字體顏色：深灰標題（#1A202C）、中灰內容（#4A5568）
```

### 3. 暖色漸層（Warm Gradient）
適合：創意提案、行銷簡報、品牌介紹
```
背景：暖色漸層（從 #FF6B6B 到 #FFA500 或 #FF8E53）
容器：白色圓角卡片帶陰影
裝飾：曲線、圓形、有機形狀
字體顏色：深色標題、白色或深灰內容
```

### 4. 深色專業（Dark Professional）
適合：技術分享、工程報告、數據分析
```
背景：深灰到黑（#0F172A 到 #1E293B）
容器：深色卡片帶淺色邊框
裝飾：網格線、數據視覺化元素
重點色：螢光綠（#10B981）或亮藍（#3B82F6）
字體顏色：白色標題、淺灰內容
```

### 5. 柔和粉彩（Soft Pastel）
適合：教育、兒童、輕鬆主題
```
背景：柔和粉彩色（淡紫、淡藍、淡粉）
容器：白色圓角卡片
裝飾：圓角形狀、手繪風格圖示
字體顏色：深色標題、中灰內容
```
