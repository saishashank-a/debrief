#!/bin/bash
# Morning Briefing Generator
# Uses Claude Code in non-interactive mode with web search
# Usage: ./generate.sh [--email]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/prompt.md"
OUTPUT_DIR="$SCRIPT_DIR/briefings"
DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="$OUTPUT_DIR/briefing-$DATE.md"

mkdir -p "$OUTPUT_DIR"

echo "📰 Generating morning briefing for $DATE..."
echo "⏰ $(date '+%H:%M:%S IST')"

# Generate briefing using Claude Code non-interactive mode
# Claude Code has built-in web search capabilities
PROMPT=$(cat "$PROMPT_FILE")
PROMPT="$PROMPT

Generate my morning briefing for today, $(date '+%B %d, %Y'). Search the web for the last 24 hours of news across all 7 topics. Include source links."

claude -p "$PROMPT" --allowedTools "WebSearch,WebFetch" > "$OUTPUT_FILE" 2>/dev/null

if [ -s "$OUTPUT_FILE" ]; then
    echo "✅ Briefing saved to $OUTPUT_FILE"

    if [ "${1:-}" = "--email" ]; then
        python3 "$SCRIPT_DIR/email_briefing.py" "$OUTPUT_FILE"
        echo "✅ Email sent"
    fi

    # Print briefing to terminal
    echo ""
    echo "═══════════════════════════════════════"
    cat "$OUTPUT_FILE"
else
    echo "❌ Failed to generate briefing"
    exit 1
fi
