#!/usr/bin/env bash
# Stream cava's output as a bar-glyph string for eww (used via deflisten).
# No-op (empty) until the `cava` CLI is installed via configuration.nix.
command -v cava >/dev/null 2>&1 || { echo ""; sleep infinity; }

CFG=$(mktemp)
cat > "$CFG" <<'EOF'
[general]
framerate = 30
bars = 16
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# bar glyphs U+2581..U+2588 (printf so the bytes are always correct)
read -ra BARS < <(printf '▁ ▂ ▃ ▄ ▅ ▆ ▇ █')

cava -p "$CFG" 2>/dev/null | while IFS= read -r line; do
    out=""
    line=${line%;}
    IFS=';' read -ra vals <<< "$line"
    for n in "${vals[@]}"; do
        [[ "$n" =~ ^[0-9]+$ ]] || continue
        (( n > 7 )) && n=7
        out+="${BARS[$n]}"
    done
    printf '%s\n' "$out"
done
