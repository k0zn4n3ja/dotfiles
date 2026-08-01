#!/usr/bin/env bash
# Show all Hyprland keybinds (parsed live from the config) in a rofi popup.
# Single awk pass = instant, no per-line subprocess spawning.
CONF="$HOME/.config/hypr/hyprland.conf"

awk '
function trim(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
function pretty(t){
    if(t=="$mainMod"||t=="SUPER") return "Super"
    if(t=="SHIFT") return "Shift"
    if(t=="CTRL")  return "Ctrl"
    if(t=="ALT")   return "Alt"
    if(t=="period")     return "."
    if(t=="comma")      return ","
    if(t=="Return")     return "Enter"
    if(t=="SPACE"||t=="space") return "Space"
    if(t=="mouse_down") return "ScrollDn"
    if(t=="mouse_up")   return "ScrollUp"
    return t
}
# variable definitions:  $terminal = kitty
/^[ \t]*\$[A-Za-z_]+[ \t]*=/ {
    eq=index($0,"="); name=trim(substr($0,1,eq-1)); vars[name]=trim(substr($0,eq+1)); next
}
# keybinds
/^[ \t]*(bind|bindm|binde|bindel|bindl)[ \t]*=/ {
    line=$0; desc=""
    h=index(line,"#"); if(h>0){ desc=trim(substr(line,h+1)); line=substr(line,1,h-1) }
    eq=index(line,"="); body=substr(line,eq+1)
    n=split(body,f,",")
    mods=trim(f[1]); key=trim(f[2]); disp=trim(f[3])
    args=""; for(i=4;i<=n;i++) args=args (i>4?",":"") f[i]; args=trim(args)

    # build "Super + Shift + X"
    combo=""; nt=split(mods,mt,/[ \t]+/)
    for(i=1;i<=nt;i++) if(mt[i]!="") combo=combo (combo==""?"":" + ") pretty(mt[i])
    combo=combo (combo==""?"":" + ") pretty(key)

    # action text
    if(disp=="exec"){
        if(desc!="") action=desc
        else { action=args; sub(/.*\/scripts\//,"",action) }
    } else {
        action=disp (args!=""?" " args:"")
        if(desc!="") action=action "  — " desc
    }
    # expand $vars in the action
    for(v in vars){ re="\\"v"([^A-Za-z_]|$)"; while(match(action,re)){ tail=substr(action,RSTART+length(v)); action=substr(action,1,RSTART-1) vars[v] tail } }

    printf "<b>%-22s</b>  %s\n", combo, action
}
' "$CONF" | rofi -dmenu -i -markup-rows -no-custom \
    -p "Keybinds" -mesg "Type to filter · Esc to close" \
    -theme-str 'window {width: 46%;} listview {lines: 15;}' >/dev/null
