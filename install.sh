#!/usr/bin/env bash
# genius-desktop installer for Debian, Ubuntu and Kali.
#   ./install.sh               terminal layer, plus the desktop layer when GNOME is installed
#   ./install.sh --boot        also the boot splash, GRUB menu and login screen (system-wide)
#   ./install.sh --no-desktop  terminal layer only
#   ./install.sh --dry-run     print what would happen, change nothing
# Safe to re-run: a file it replaces is kept next to it as NAME.bak-genius-DATE.
set -euo pipefail

REPO=$(cd "$(dirname "$0")" && pwd)
STAMP=$(date +%Y%m%d-%H%M%S)
DRY=0 BOOT=0 DESKTOP=auto
for a in "$@"; do
  case $a in
    --dry-run) DRY=1 ;;
    --boot) BOOT=1 ;;
    --no-desktop) DESKTOP=0 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "unknown option: $a (see --help)" >&2; exit 1 ;;
  esac
done
[[ $EUID -eq 0 ]] && { echo "Run as your normal user; sudo is asked for when needed." >&2; exit 1; }
command -v apt-get >/dev/null || { echo "Only Debian, Ubuntu and Kali (apt) are supported." >&2; exit 1; }
# gsettings needs a session bus: over SSH borrow the logged-in one, or start a private one
if [[ -z ${DBUS_SESSION_BUS_ADDRESS:-} && $DESKTOP != 0 ]] && command -v gnome-shell >/dev/null; then
  if [[ -S /run/user/$UID/bus ]]; then export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UID/bus
  elif [[ -z ${GENIUS_DBUS:-} ]] && command -v dbus-run-session >/dev/null; then GENIUS_DBUS=1 exec dbus-run-session -- "$0" "$@"; fi
fi

say()  { printf '\033[1;38;2;111;227;232m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;38;2;176;124;255m  !\033[0m %s\n' "$*"; }
run()  { if ((DRY)); then printf '    [dry-run] %s\n' "$*"; else "$@"; fi; }

# install only the packages this release has; report the rest
apt_install() {
  local ok=() p
  for p in "$@"; do
    if [[ $(LC_ALL=C apt-cache policy "$p" 2>/dev/null) == *'Candidate: '[0-9]* ]]; then ok+=("$p"); else warn "not in your repos, skipped: $p"; MISSING+=" $p "; fi
  done
  ((${#ok[@]} == 0)) || run sudo apt-get install -y --no-install-recommends "${ok[@]}"
}

MISSING=""
export PATH="$HOME/.local/bin:$PATH"   # so re-runs see the release binaries installed below

# copy a tree into $HOME, keeping a backup of any file that differs
deploy() {
  local src=$1 f rel dst
  while IFS= read -r -d '' f; do
    rel=${f#"$src"/}; dst=$HOME/$rel
    [[ -e $dst ]] && cmp -s "$f" "$dst" && continue
    run mkdir -p "$(dirname "$dst")"
    [[ -e $dst ]] && run mv "$dst" "$dst.bak-genius-$STAMP"
    run cp "$f" "$dst"
  done < <(find "$src" -type f -print0)
}

# ---------------------------------------------------------------- terminal
say "Terminal layer: packages"
run sudo apt-get update -qq
apt_install zsh tmux git curl unzip python3 fzf bat eza zoxide fastfetch figlet glow btop cava cmatrix \
  pipes-sh yazi lazygit starship tealdeer asciinema ffmpeg xclip libnotify-bin \
  zsh-autosuggestions zsh-syntax-highlighting ghostty
if [[ $MISSING == *" starship "* ]] && ! command -v starship >/dev/null; then
  say "starship is not packaged here: installing the official release into ~/.local/bin"
  run mkdir -p "$HOME/.local/bin"
  ((DRY)) || curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" >/dev/null
fi
if [[ $MISSING == *" yazi "* ]] && ! command -v yazi >/dev/null; then
  say "yazi is not packaged here: installing the official release into ~/.local/bin"
  if ((DRY)); then echo "    [dry-run] download yazi-$(uname -m)-unknown-linux-gnu.zip"; else
    tmp=$(mktemp -d)
    curl -fsSL "https://github.com/sxyazi/yazi/releases/latest/download/yazi-$(uname -m)-unknown-linux-gnu.zip" -o "$tmp/y.zip" \
      && unzip -q "$tmp/y.zip" -d "$tmp" && mkdir -p "$HOME/.local/bin" && cp "$tmp"/yazi-*/{yazi,ya} "$HOME/.local/bin/" \
      || warn "yazi download failed, skipped"
    rm -rf "$tmp"
  fi
fi

say "Terminal layer: configs"
deploy "$REPO/home"
LINE='[[ -r ~/.config/genius-desktop/genius.zsh ]] && source ~/.config/genius-desktop/genius.zsh'
grep -qF "$LINE" "$HOME/.zshrc" 2>/dev/null || { ((DRY)) && echo "    [dry-run] append source line to ~/.zshrc" || printf '\n# genius-desktop\n%s\n' "$LINE" >> "$HOME/.zshrc"; }
if [[ -f $HOME/.config/btop/btop.conf ]]; then
  run sed -i 's/^color_theme = .*/color_theme = "anonymous"/' "$HOME/.config/btop/btop.conf"
else
  ((DRY)) || echo 'color_theme = "anonymous"' > "$HOME/.config/btop/btop.conf"
fi
((DRY)) || (command -v tldr >/dev/null && tldr --update >/dev/null 2>&1 || true)
if [[ $(getent passwd "$USER" | cut -d: -f7) != */zsh ]]; then
  say "Making zsh your login shell"
  run sudo chsh -s "$(command -v zsh)" "$USER"
fi

# ---------------------------------------------------------------- desktop
if [[ $DESKTOP == auto ]]; then command -v gnome-shell >/dev/null && DESKTOP=1 || DESKTOP=0; fi
if ((DESKTOP)); then
  shell_major=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)

  say "Desktop layer (GNOME $shell_major): packages"
  apt_install papirus-icon-theme bibata-cursor-theme conky-all

  say "Desktop layer: configs, sounds, cube sky box"
  deploy "$REPO/desktop"
  iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
  run sed -i "s/IFACE/${iface:-eth0}/g" "$HOME/.config/conky/anonymous.conf"

  # Papirus-Dark with cyan folders, as a small user theme (no system files touched)
  if [[ -d /usr/share/icons/Papirus-Dark ]]; then
    say "Icons: Papirus-Dark-Cyan"
    ico=$HOME/.local/share/icons/Papirus-Dark-Cyan dirs=()
    if ((DRY)); then echo "    [dry-run] build $ico from Papirus-Dark *-cyan* folder icons"; else
      for d in /usr/share/icons/Papirus-Dark/*/places; do
        size=$(basename "$(dirname "$d")"); dirs+=("$size/places")
        mkdir -p "$ico/$size/places"
        for f in "$d"/*-cyan*.svg; do [[ -e $f ]] && cp -L "$f" "$ico/$size/places/$(basename "${f/-cyan/}")"; done
      done
      { printf '[Icon Theme]\nName=Papirus-Dark-Cyan\nComment=Papirus-Dark with cyan folders\nInherits=Papirus-Dark,breeze-dark,hicolor\nDirectories=%s\n' "$(IFS=,; echo "${dirs[*]}")"
        for s in "${dirs[@]}"; do printf '\n[%s]\nSize=%s\nScale=%s\nContext=Places\nType=Fixed\n' "$s" "${s%%x*}" "$([[ $s == *@2x* ]] && echo 2 || echo 1)"; done
      } > "$ico/index.theme"
    fi
  fi

  say "GNOME extensions (active after your next login)"
  exts=(Vitals@CoreCoding.com desktop-cube@schneegans.github.com CoverflowAltTab@palatis.blogspot.com burn-my-windows@schneegans.github.com)
  for u in "${exts[@]}"; do
    url=$(curl -fsS "https://extensions.gnome.org/extension-info/?uuid=$u&shell_version=$shell_major" 2>/dev/null \
      | python3 -c 'import json,sys; print(json.load(sys.stdin)["download_url"])' 2>/dev/null) \
      || { warn "$u has no release for GNOME $shell_major yet, skipped"; continue; }
    dst=$HOME/.local/share/gnome-shell/extensions/$u
    ver=$(curl -fsS "https://extensions.gnome.org/extension-info/?uuid=$u&shell_version=$shell_major" | python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])' 2>/dev/null || true)
    if [[ -n $ver ]] && grep -qE "\"version\": *$ver\b" "$dst/metadata.json" 2>/dev/null; then echo "    $u is up to date"; continue; fi
    if ((DRY)); then echo "    [dry-run] download $u into $dst"; continue; fi
    tmp=$(mktemp --suffix=.zip); curl -fsSL "https://extensions.gnome.org$url" -o "$tmp"
    rm -rf "$dst"; mkdir -p "$dst"; unzip -oq "$tmp" -d "$dst"; rm -f "$tmp"
    [[ -d $dst/schemas ]] && glib-compile-schemas "$dst/schemas"
    python3 - "$u" <<'EOF'
import ast, subprocess, sys
cur = subprocess.run(["gsettings", "get", "org.gnome.shell", "enabled-extensions"], capture_output=True, text=True).stdout.strip()
cur = ast.literal_eval(cur.removeprefix("@as ")) if cur else []
if sys.argv[1] not in cur:
    subprocess.run(["gsettings", "set", "org.gnome.shell", "enabled-extensions", str(cur + [sys.argv[1]])], check=True)
EOF
  done
  run dconf write /org/gnome/shell/extensions/desktop-cube/background-panorama "'$HOME/.local/share/backgrounds/cube-skybox.jpg'"

  say "GNOME look: dark, icons, cursor, sounds"
  gset() { run gsettings set "$@" 2>/dev/null || warn "setting not available here: $*"; }
  gset org.gnome.desktop.interface color-scheme prefer-dark
  gset org.gnome.desktop.interface accent-color slate
  [[ -d /usr/share/themes/Yaru-dark ]] && gset org.gnome.desktop.interface gtk-theme Yaru-dark
  [[ -d $HOME/.local/share/icons/Papirus-Dark-Cyan ]] && gset org.gnome.desktop.interface icon-theme Papirus-Dark-Cyan
  [[ -d /usr/share/icons/Bibata-Modern-Classic ]] && gset org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic
  gset org.gnome.desktop.sound theme-name Anonymous
  gset org.gnome.desktop.sound event-sounds true
else
  say "No GNOME found: desktop layer skipped"
fi

# ---------------------------------------------------------------- boot (opt-in, system-wide)
if ((BOOT)); then
  say "Boot splash (Plymouth)"
  apt_install plymouth plymouth-themes
  run sudo rm -rf /usr/share/plymouth/themes/anonymous
  run sudo cp -r "$REPO/system/plymouth" /usr/share/plymouth/themes/anonymous
  run sudo plymouth-set-default-theme -R anonymous

  say "GRUB menu"
  run sudo rm -rf /boot/grub/themes/anonymous
  run sudo mkdir -p /boot/grub/themes
  run sudo cp -r "$REPO/system/grub" /boot/grub/themes/anonymous
  run sudo cp /etc/default/grub "/etc/default/grub.bak-genius-$STAMP"
  run sudo sed -i '/^#\?GRUB_THEME=/d' /etc/default/grub
  ((DRY)) || echo 'GRUB_THEME="/boot/grub/themes/anonymous/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null
  grep -q 'GRUB_CMDLINE_LINUX_DEFAULT=.*splash' /etc/default/grub || run sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&splash /' /etc/default/grub
  run sudo update-grub

  if [[ -d /etc/gdm3 ]]; then
    say "Login screen wallpaper (gdm-extension, pinned upstream commit)"
    # ponytail: pinned to a reviewed commit; bump GDMEXT after reading the new diff
    GDMEXT=f7c249e91f40ba8d293338085708938b9cc00b55
    run sudo cp "$REPO/system/login.png" /usr/share/backgrounds/genius-login.png
    if ((DRY)); then echo "    [dry-run] install gse-gdm-extension $GDMEXT"; else
      tmp=$(mktemp -d)
      git clone -q https://github.com/pratap-panabaka/gse-gdm-extension "$tmp/gdmext"
      git -C "$tmp/gdmext" checkout -q "$GDMEXT"
      (cd "$tmp/gdmext" && sudo ./install.sh)
      printf "[org/gnome/shell/extensions/gdm-extension]\nbackground-image-path-1='/usr/share/backgrounds/genius-login.png'\nbackground-size-1='cover'\nblur-radius-1=0\nhide-gdm-extension-button=true\n" \
        | sudo tee /etc/dconf/db/gdm.d/99-zz-genius >/dev/null
      sudo dconf update
      rm -rf "$tmp"
    fi
  else
    warn "GDM not found: login screen skipped"
  fi
fi

say "Done. Open a new terminal (or log out and back in for the desktop). Type 'cheat' for the cheat sheet."
