# Changelog

所有重要變更都會記錄在此檔案中。格式基於 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/)。

## [1.1.0] - 2026-03-17

### 新增
- `bash install.sh --verify` 驗證指令，快速檢查安裝狀態
- VERSION 檔案與 CHANGELOG 變更日誌
- 離線模式偵測與降級提示
- 多語言簡報支援（繁體中文、簡體中文、英文）
- 網路連線偵測，離線時自動限制為本地來源

### 改善
- 安裝驗證輸出更清晰，包含通過/可選/失敗計數
- README 加入驗證指令說明與範例輸出
- SKILL.md 錯誤處理表加入離線相關情境

## [1.0.0] - 2026-03-17

### 新增
- 三種模式自動適配：Lite、Standard、Full
- 7 步驟自動化流程：環境偵測 → 輸入收集 → 內容擷取 → 研究分析 → 結構規劃 → 簡報生成 → 輸出
- 5 種內建視覺風格
- Gemini 提示詞生成器（免費 AI 圖片途徑）
- NotebookLM 深度研究整合
- YouTube MCP 字幕擷取整合
- NanoBanana PPT 升級路線
- 跨平台安裝腳本（macOS、Linux、WSL、Git Bash）
- Gemini CLI 支援（AGENTS.md）
