function list-ssh --description 'List SSH host aliases from ~/.ssh/config'
    awk 'function out() { if (h) printf "%-12s %s@%s\n", h, u, n }
        /^Host /{ out(); h = ($2 ~ /[*?]/) ? "" : $2; u = ""; n = "" }
        /^[ \t]*HostName /{ n = $2 }
        /^[ \t]*User /{ u = $2 }
        END { out() }' ~/.ssh/config
end
