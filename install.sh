#!/usr/bin/env bash
# ============================================================================
# Presentation Master — 跨平台安裝腳本
#
# 支援：macOS, Linux (Ubuntu/Debian/Fedora/Arch), Windows (Git Bash/WSL)
# 用法：bash install.sh [--lite | --standard | --full]
# ============================================================================

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 安裝目標
SKILL_DIR="$HOME/.claude/skills/presentation-master"
PPT_GEN_DIR="$HOME/.claude/skills/ppt-generator"
ORIG_DIR="$(pwd)"

# 偵測作業系統
detect_os() {
  case "$(uname -s)" in
    Darwin*)  OS="macos" ;;
    Linux*)
      if grep -q Microsoft /proc/version 2>/dev/null; then
        OS="wsl"
      else
        OS="linux"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows_git_bash" ;;
    *) OS="unknown" ;;
  esac
  echo -e "${CYAN}偵測到作業系統：${OS}${NC}"
}

# 偵測 Linux 發行版
detect_distro() {
  if [ "$OS" = "linux" ] || [ "$OS" = "wsl" ]; then
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      DISTRO="$ID"
    elif command -v lsb_release &>/dev/null; then
      DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
      DISTRO="unknown"
    fi
  fi
}

# 偵測套件管理器
detect_pkg_manager() {
  if command -v brew &>/dev/null; then
    PKG_MGR="brew"
  elif command -v apt-get &>/dev/null; then
    PKG_MGR="apt"
  elif command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
  elif command -v pacman &>/dev/null; then
    PKG_MGR="pacman"
  elif command -v apk &>/dev/null; then
    PKG_MGR="apk"
  else
    PKG_MGR="none"
  fi
}

# 偵測 Python
detect_python() {
  if command -v python3 &>/dev/null; then
    PYTHON="python3"
  elif command -v python &>/dev/null; then
    PYTHON="python"
  else
    PYTHON=""
  fi

  if command -v pip3 &>/dev/null; then
    PIP="pip3"
  elif command -v pip &>/dev/null; then
    PIP="pip"
  else
    PIP=""
  fi
}

# 偵測 Node.js
detect_node() {
  if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version 2>/dev/null)
    HAS_NODE=true
  else
    HAS_NODE=false
  fi

  if command -v npm &>/dev/null; then
    HAS_NPM=true
  else
    HAS_NPM=false
  fi
}

# 印出標題
print_header() {
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}  Presentation Master — 全方位簡報生成技能${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# 安裝核心技能（所有模式都需要）
install_core() {
  echo -e "${BLUE}[1/4] 安裝核心技能檔案...${NC}"

  # 取得腳本所在目錄
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # 建立目標目錄
  mkdir -p "$SKILL_DIR/templates"

  # 複製核心檔案
  cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
  cp "$SCRIPT_DIR/templates/gemini-prompt-template.md" "$SKILL_DIR/templates/" 2>/dev/null || true

  echo -e "${GREEN}  ✓ 核心技能已安裝到 $SKILL_DIR${NC}"
}

# 安裝 pptx 相關依賴（Standard / Full）
install_pptx_deps() {
  echo -e "${BLUE}[2/4] 檢查 .pptx 生成依賴...${NC}"

  if [ "$HAS_NODE" = false ]; then
    echo -e "${YELLOW}  ⚠ 未偵測到 Node.js — 跳過 .pptx 支援${NC}"
    echo -e "${YELLOW}    安裝 Node.js 後可執行：npm install -g pptxgenjs sharp${NC}"
    return
  fi

  # 檢查 pptxgenjs（全域或本地）
  if ! npm list -g pptxgenjs 2>/dev/null | grep -q pptxgenjs && \
     ! node -e "require('pptxgenjs')" 2>/dev/null; then
    echo -e "${YELLOW}  安裝 pptxgenjs...${NC}"
    npm install -g pptxgenjs 2>/dev/null || {
      echo -e "${YELLOW}  ⚠ 全域安裝失敗，嘗試本地安裝...${NC}"
      mkdir -p "$SKILL_DIR/node_modules"
      cd "$SKILL_DIR" && npm install pptxgenjs 2>/dev/null || true
      cd - > /dev/null
    }
  else
    echo -e "${GREEN}  ✓ pptxgenjs 已安裝${NC}"
  fi

  # 檢查 sharp（全域或本地）
  if ! npm list -g sharp 2>/dev/null | grep -q sharp && \
     ! node -e "require('sharp')" 2>/dev/null; then
    echo -e "${YELLOW}  安裝 sharp...${NC}"
    npm install -g sharp 2>/dev/null || {
      # 全域失敗，嘗試本地
      mkdir -p "$SKILL_DIR/node_modules"
      cd "$SKILL_DIR" && npm install sharp 2>/dev/null && cd "$ORIG_DIR" || {
        cd "$ORIG_DIR" 2>/dev/null
        echo -e "${YELLOW}  ⚠ sharp 安裝失敗（可選，不影響基本功能）${NC}"
      }
    }
  else
    echo -e "${GREEN}  ✓ sharp 已安裝${NC}"
  fi

  # 檢查 playwright（全域或本地）
  if ! npm list -g playwright 2>/dev/null | grep -q playwright && \
     ! node -e "require('playwright')" 2>/dev/null; then
    echo -e "${YELLOW}  安裝 playwright...${NC}"
    npm install -g playwright 2>/dev/null || {
      mkdir -p "$SKILL_DIR/node_modules"
      cd "$SKILL_DIR" && npm install playwright 2>/dev/null && cd "$ORIG_DIR" || {
        cd "$ORIG_DIR" 2>/dev/null
        echo -e "${YELLOW}  ⚠ playwright 安裝失敗（可選）${NC}"
      }
    }
    npx playwright install chromium 2>/dev/null || true
  else
    echo -e "${GREEN}  ✓ playwright 已安裝${NC}"
  fi

  # 檢查 LibreOffice（排版驗證用）
  if command -v soffice &>/dev/null; then
    echo -e "${GREEN}  ✓ LibreOffice 已安裝（排版驗證可用）${NC}"
  else
    echo -e "${YELLOW}  ⚠ LibreOffice 未安裝（排版驗證不可用，不影響簡報生成）${NC}"
    case "$PKG_MGR" in
      brew)   echo -e "${YELLOW}    安裝方式：brew install --cask libreoffice${NC}" ;;
      apt)    echo -e "${YELLOW}    安裝方式：sudo apt-get install libreoffice${NC}" ;;
      dnf)    echo -e "${YELLOW}    安裝方式：sudo dnf install libreoffice${NC}" ;;
      pacman) echo -e "${YELLOW}    安裝方式：sudo pacman -S libreoffice${NC}" ;;
    esac
  fi
}

# 安裝 NanoBanana（可選）
install_nanobanana() {
  echo -e "${BLUE}[3/4] 安裝 NanoBanana PPT（可選，AI 圖片生成）...${NC}"

  if [ -d "$PPT_GEN_DIR" ]; then
    echo -e "${YELLOW}  NanoBanana 已安裝於 $PPT_GEN_DIR${NC}"
    if [ "$OS" = "windows_git_bash" ]; then
      echo -e "${YELLOW}  Git Bash 偵測到，自動跳過覆蓋（刪除目錄後重新安裝）${NC}"
      echo -e "${GREEN}  ✓ 保留現有安裝${NC}"
      return
    fi
    read -p "  是否覆蓋？(y/N) " REPLY
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${GREEN}  ✓ 保留現有安裝${NC}"
      return
    fi
  fi

  # 檢查 Python
  if [ -z "$PYTHON" ]; then
    echo -e "${YELLOW}  ⚠ 未偵測到 Python — 跳過 NanoBanana 安裝${NC}"
    return
  fi

  # Clone 到暫存目錄
  TEMP_DIR=$(mktemp -d 2>/dev/null || echo "/tmp/presentation-master-$$")
  mkdir -p "$TEMP_DIR"
  trap "rm -rf '$TEMP_DIR'" EXIT
  echo -e "${YELLOW}  正在從 GitHub 下載 NanoBanana...${NC}"
  ORIG_DIR="$(pwd)"
  if git clone --depth 1 https://github.com/op7418/NanoBanana-PPT-Skills.git "$TEMP_DIR/nanobanana" 2>/dev/null; then
    cd "$TEMP_DIR/nanobanana"

    # 嘗試用原生安裝腳本
    if [ -f install_as_skill.sh ]; then
      bash install_as_skill.sh || {
        # 手動安裝 fallback
        echo -e "${YELLOW}  原生安裝腳本失敗，使用手動安裝...${NC}"
        mkdir -p "$PPT_GEN_DIR"
        cp -r generate_ppt.py styles/ prompts/ templates/ "$PPT_GEN_DIR/" 2>/dev/null || true
        cp SKILL.md "$PPT_GEN_DIR/" 2>/dev/null || true

        # 安裝 Python 依賴
        if [ -n "$PIP" ]; then
          $PIP install google-genai pillow python-dotenv 2>/dev/null || true
        fi
      }
    else
      # 無安裝腳本，手動安裝
      mkdir -p "$PPT_GEN_DIR"
      cp -r generate_ppt.py styles/ prompts/ templates/ "$PPT_GEN_DIR/" 2>/dev/null || true
      cp SKILL.md "$PPT_GEN_DIR/" 2>/dev/null || true

      if [ -n "$PIP" ]; then
        $PIP install google-genai pillow python-dotenv 2>/dev/null || true
      fi
    fi

    cd "$ORIG_DIR"
    echo -e "${GREEN}  ✓ NanoBanana 已安裝到 $PPT_GEN_DIR${NC}"
  else
    echo -e "${YELLOW}  ⚠ 無法下載 NanoBanana（需要網路連線）${NC}"
    echo -e "${YELLOW}    稍後可手動安裝：${NC}"
    echo -e "${YELLOW}    git clone https://github.com/op7418/NanoBanana-PPT-Skills.git${NC}"
    echo -e "${YELLOW}    cd NanoBanana-PPT-Skills && bash install_as_skill.sh${NC}"
  fi

  # 清理暫存目錄
  rm -rf "$TEMP_DIR"
}

# 驗證安裝結果
verify_installation() {
  echo -e "${BLUE}[4/4] 驗證安裝結果...${NC}"
  echo ""

  AVAILABLE_MODE="Lite"

  # 檢查核心
  if [ -f "$SKILL_DIR/SKILL.md" ]; then
    echo -e "${GREEN}  ✓ 核心技能 (SKILL.md)${NC}"
  else
    echo -e "${RED}  ✗ 核心技能安裝失敗${NC}"
    exit 1
  fi

  # 檢查 pptx 工具
  if npm list -g pptxgenjs 2>/dev/null | grep -q pptxgenjs || \
     node -e "require('pptxgenjs')" 2>/dev/null; then
    echo -e "${GREEN}  ✓ pptxgenjs（.pptx 生成可用）${NC}"
    AVAILABLE_MODE="Standard"
  else
    echo -e "${YELLOW}  ○ pptxgenjs（未安裝，無 .pptx 輸出）${NC}"
  fi

  # 檢查 NotebookLM
  if command -v notebooklm &>/dev/null; then
    if notebooklm login --check 2>/dev/null; then
      echo -e "${GREEN}  ✓ NotebookLM（已認證，深度研究可用）${NC}"
      if [ "$AVAILABLE_MODE" = "Standard" ]; then
        AVAILABLE_MODE="Full"
      fi
    else
      echo -e "${YELLOW}  ○ NotebookLM（未認證，執行 notebooklm login 啟用）${NC}"
    fi
  else
    echo -e "${YELLOW}  ○ NotebookLM（未安裝）${NC}"
  fi

  # 檢查 NanoBanana
  if [ -f "$PPT_GEN_DIR/generate_ppt.py" ]; then
    echo -e "${GREEN}  ✓ NanoBanana PPT（AI 圖片生成可用）${NC}"
  else
    echo -e "${YELLOW}  ○ NanoBanana PPT（未安裝，可用 Gemini 提示詞替代）${NC}"
  fi

  # 檢查 YouTube MCP
  echo -e "${YELLOW}  ○ YouTube MCP（需在 Claude Code 中確認）${NC}"

  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}  安裝完成！目前可用模式：${AVAILABLE_MODE}${NC}"
  echo ""
  echo -e "  使用方式：在 Claude Code 中說「幫我做一份簡報」"
  echo -e "  技能位置：$SKILL_DIR"
  echo ""

  if [ "$AVAILABLE_MODE" = "Lite" ]; then
    echo -e "${YELLOW}  提升建議：${NC}"
    echo -e "${YELLOW}  → 安裝 Node.js + npm 升級為 Standard 模式（可輸出 .pptx）${NC}"
    echo -e "${YELLOW}  → 安裝 notebooklm-py 升級為 Full 模式（深度研究）${NC}"
  fi

  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 獨立驗證（--verify 專用）
verify_only() {
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}  Presentation Master — 安裝狀態驗證${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  PASS=0
  WARN=0
  FAIL=0
  AVAILABLE_MODE="Lite"

  # 版本資訊
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/VERSION" ]; then
    echo -e "  版本：$(cat "$SCRIPT_DIR/VERSION")"
  fi
  echo ""

  # 1. 核心技能
  if [ -f "$SKILL_DIR/SKILL.md" ]; then
    echo -e "${GREEN}  ✓ 核心技能 (SKILL.md)${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}  ✗ 核心技能未安裝${NC}"
    echo -e "${RED}    修復：bash install.sh${NC}"
    FAIL=$((FAIL + 1))
  fi

  # 2. Node.js
  if command -v node &>/dev/null; then
    echo -e "${GREEN}  ✓ Node.js $(node --version)${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}  ○ Node.js 未安裝（Standard 模式需要）${NC}"
    WARN=$((WARN + 1))
  fi

  # 3. pptxgenjs
  if npm list -g pptxgenjs 2>/dev/null | grep -q pptxgenjs || \
     node -e "require('pptxgenjs')" 2>/dev/null; then
    echo -e "${GREEN}  ✓ pptxgenjs（.pptx 生成可用）${NC}"
    AVAILABLE_MODE="Standard"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}  ○ pptxgenjs 未安裝（無 .pptx 輸出）${NC}"
    WARN=$((WARN + 1))
  fi

  # 4. sharp
  if npm list -g sharp 2>/dev/null | grep -q sharp || \
     node -e "require('sharp')" 2>/dev/null; then
    echo -e "${GREEN}  ✓ sharp（圖片處理可用）${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}  ○ sharp 未安裝（可選）${NC}"
    WARN=$((WARN + 1))
  fi

  # 5. playwright
  if npm list -g playwright 2>/dev/null | grep -q playwright || \
     node -e "require('playwright')" 2>/dev/null; then
    echo -e "${GREEN}  ✓ playwright（HTML 渲染可用）${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}  ○ playwright 未安裝（可選）${NC}"
    WARN=$((WARN + 1))
  fi

  # 6. Python
  if command -v python3 &>/dev/null; then
    echo -e "${GREEN}  ✓ Python $(python3 --version 2>&1 | awk '{print $2}')${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}  ○ Python 未安裝（Full 模式需要）${NC}"
    WARN=$((WARN + 1))
  fi

  # 7. NotebookLM
  if command -v notebooklm &>/dev/null; then
    if notebooklm login --check 2>/dev/null; then
      echo -e "${GREEN}  ✓ NotebookLM（已認證）${NC}"
      if [ "$AVAILABLE_MODE" = "Standard" ]; then
        AVAILABLE_MODE="Full"
      fi
      PASS=$((PASS + 1))
    else
      echo -e "${YELLOW}  ○ NotebookLM（未認證，執行 notebooklm login）${NC}"
      WARN=$((WARN + 1))
    fi
  else
    echo -e "${YELLOW}  ○ NotebookLM 未安裝${NC}"
    WARN=$((WARN + 1))
  fi

  # 8. NanoBanana
  if [ -f "$PPT_GEN_DIR/generate_ppt.py" ]; then
    echo -e "${GREEN}  ✓ NanoBanana PPT（AI 圖片生成可用）${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}  ○ NanoBanana PPT 未安裝（可用 Gemini 提示詞替代）${NC}"
    WARN=$((WARN + 1))
  fi

  # 9. 網路連線
  if ping -c 1 -W 3 google.com &>/dev/null 2>&1; then
    echo -e "${GREEN}  ✓ 網路連線正常${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}  ⚠ 無網路連線（僅限離線模式：本地文件 + 主題關鍵字）${NC}"
    WARN=$((WARN + 1))
  fi

  # 10. Gemini API Key
  if [ -n "$GEMINI_API_KEY" ]; then
    echo -e "${GREEN}  ✓ Gemini API Key 已設定${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}  ○ Gemini API Key 未設定（NanoBanana 需要，Gemini 提示詞不需要）${NC}"
    WARN=$((WARN + 1))
  fi

  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  結果：${GREEN}${PASS} 通過${NC} | ${YELLOW}${WARN} 可選${NC} | ${RED}${FAIL} 失敗${NC}"
  echo -e "  可用模式：${GREEN}${AVAILABLE_MODE}${NC}"
  echo ""
  if [ "$FAIL" -eq 0 ]; then
    echo -e "  ${GREEN}安裝正常！在 Claude Code 中說「幫我做一份簡報」即可使用。${NC}"
  else
    echo -e "  ${RED}有元件安裝失敗，請執行 bash install.sh 修復。${NC}"
  fi
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 主流程
main() {
  print_header
  detect_os
  detect_distro
  detect_pkg_manager
  detect_python
  detect_node

  echo ""

  # 解析參數
  INSTALL_MODE="auto"
  for arg in "$@"; do
    case "$arg" in
      --lite)     INSTALL_MODE="lite" ;;
      --standard) INSTALL_MODE="standard" ;;
      --full)     INSTALL_MODE="full" ;;
      --verify)
        verify_only
        exit 0
        ;;
      --help|-h)
        echo "用法：bash install.sh [--lite | --standard | --full | --verify]"
        echo ""
        echo "  --lite      只安裝核心技能（零依賴）"
        echo "  --standard  安裝核心 + .pptx 依賴"
        echo "  --full      安裝所有功能（含 NanoBanana）"
        echo "  --verify    驗證安裝狀態（不安裝任何東西）"
        echo ""
        echo "  不指定參數時自動偵測環境並安裝可用的功能。"
        exit 0
        ;;
    esac
  done

  # Step 1: 核心安裝（所有模式）
  install_core

  # Step 2: pptx 依賴（standard / full / auto）
  if [ "$INSTALL_MODE" != "lite" ]; then
    install_pptx_deps
  fi

  # Step 3: NanoBanana（full / auto）
  if [ "$INSTALL_MODE" = "full" ] || [ "$INSTALL_MODE" = "auto" ]; then
    install_nanobanana
  fi

  # Step 4: 驗證
  verify_installation
}

main "$@"
