# genius-desktop shell layer, sourced from ~/.zshrc (one line added by install.sh).
# Every block checks for its tool, so a missing package never breaks the shell.

export PATH="$HOME/.local/bin:$PATH"

# Banner + system info in a fresh terminal; one-line welcome inside tmux or over SSH
if [[ -t 1 && -z "$CLAUDECODE" && -z "$GENIUS_QUIET" ]]; then
  if [[ -n $TMUX || -n $SSH_CONNECTION ]]; then genius-motd
  else command -v figlet >/dev/null && genius-banner; command -v fastfetch >/dev/null && fastfetch; fi
fi

# Debian/Kali/Ubuntu package names (Oh My Zsh users usually load these as plugins already)
(( $+functions[_zsh_autosuggest_start] )) || {
  [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
}

# starship prompt (~/.config/starship.toml)
command -v starship >/dev/null && eval "$(starship init zsh)"

# Ghostty shell integration (cwd, title, prompt marks), no-op outside Ghostty
if [[ -n ${GHOSTTY_RESOURCES_DIR:-} ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

# eza: cold-colored listings (no icons, so no special font needed)
if command -v eza >/dev/null; then
  export EZA_COLORS="di=1;38;2;108;170;255:ex=1;38;2;111;227;232:ln=38;2;176;124;255:or=38;2;176;95;109:fi=38;2;201;212;222:ur=38;2;111;227;232:uw=38;2;176;124;255:ux=38;2;108;170;255:ue=38;2;108;170;255:gr=38;2;111;179;184:gw=38;2;139;127;179:gx=38;2;108;143;179:tr=38;2;111;179;184:tw=38;2;139;127;179:tx=38;2;108;143;179:sn=38;2;111;227;232:sb=38;2;77;93;109:uu=38;2;176;124;255:gu=38;2;140;140;255:da=38;2;77;93;109:ga=38;2;111;227;232:gm=38;2;108;170;255:gd=38;2;176;95;109:gv=38;2;176;124;255:gt=38;2;140;140;255:hd=4;38;2;143;166;189:*.zip=38;2;176;124;255:*.tar=38;2;176;124;255:*.gz=38;2;176;124;255:*.xz=38;2;176;124;255:*.7z=38;2;176;124;255:*.deb=38;2;176;124;255:*.md=38;2;198;246;255:*.pdf=38;2;140;140;255"
  alias ls='eza --group-directories-first'
  alias ll='eza -l --git --group-directories-first --time-style=relative --header'
  alias la='eza -la --git --group-directories-first --time-style=relative --header'
  alias lt='eza --tree --level=2 --group-directories-first'
fi

# fzf: Ctrl+R history search, Ctrl+T file picker, Alt+C cd (cold palette)
if command -v fzf >/dev/null; then
  export FZF_DEFAULT_OPTS="--height=45% --layout=reverse --border=rounded --info=inline \
--color=bg+:#1c2731,bg:-1,spinner:#6fe3e8,hl:#b07cff,fg:#c9d4de,header:#6caaff,info:#4d5d6d \
--color=pointer:#6fe3e8,marker:#b07cff,fg+:#e6edf3,prompt:#6fe3e8,hl+:#b07cff,border:#3a4652"
  # fzf >= 0.48 has --zsh; older Debian packages ship the scripts instead
  if fzf --zsh >/dev/null 2>&1; then source <(fzf --zsh)
  else
    [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
  fi
fi

# bat (Debian names it batcat): syntax-highlighted cat, plain in pipes
if command -v batcat >/dev/null; then alias bat='batcat'; alias cat='batcat --paging=never'
elif command -v bat >/dev/null; then alias cat='bat --paging=never'; fi

# zoxide: "z proj" jumps to frequently used folders
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# yazi: "y" opens the file manager and cd's into the folder you quit in
function y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then builtin cd -- "$cwd"; fi
  rm -f -- "$tmp"
}

# Desktop notification when a command ran 30 s or more (skips full-screen/interactive tools)
zmodload zsh/datetime
_notify_skip='^(vim|nvim|nano|less|more|man|btop|htop|top|tmux|ssh|y|yazi|lazygit|cava|cava-idle|glow|mission|fzf|watch|tail -f|python3?|ipython|node|sqlplus|mysql|psql)( |$)'
_cmd_start() { _cmd_t0=$EPOCHREALTIME; _cmd_txt=$1 }
_cmd_done() {
  local rc=$? t0=$_cmd_t0; unset _cmd_t0
  [[ -z $t0 || -z $DISPLAY$WAYLAND_DISPLAY || $_cmd_txt =~ $_notify_skip ]] && return
  command -v notify-send >/dev/null || return
  local s=$(( ${EPOCHREALTIME%.*} - ${t0%.*} ))
  (( s < 30 )) && return
  local d="${s}s"; (( s >= 60 )) && d="$((s/60))m $((s%60))s"
  if (( rc == 0 )); then notify-send -a Terminal -i utilities-terminal "Done in $d" "$_cmd_txt"
  else notify-send -a Terminal -u critical -i dialog-error "Failed (exit $rc) after $d" "$_cmd_txt"; fi
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _cmd_start
add-zsh-hook precmd _cmd_done

# hide the "%" partial-line marker (shows in new tmux panes)
PROMPT_EOL_MARK=""

# cheat sheet for all of the above
alias cheat="glow ~/.config/genius-desktop/CHEATSHEET.md"

# resume: pick any past Cursor agent or Claude Code chat from any folder (newest first), jump there, resume it.
#   resume          all chats        resume agent / resume claude    one tool only
resume() {
  local filter=${1:-} pick tool cwd id
  pick=$(chat-index | { [[ -n $filter ]] && awk -F'\t' -v t="$filter" '$2==t' || command cat; } \
    | fzf --delimiter='\t' --with-nth=5 --no-sort --prompt='resume > ' \
          --header='date              tool    folder                                  title') || return
  IFS=$'\t' read -r _ tool cwd id _ <<< "$pick"
  [[ -d $cwd ]] || { print -u2 "resume: folder no longer exists: $cwd"; return 1; }
  cd "$cwd" || return
  if [[ $tool == agent ]]; then agent --resume "$id"; else claude --resume "$id"; fi
}

# syntax highlighting must load last
(( $+functions[_zsh_highlight] )) || {
  [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
}
