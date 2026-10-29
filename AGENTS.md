# genius-desktop

Installer that reproduces a cold, dark GNOME desktop and zsh/tmux terminal on Debian, Ubuntu and Kali. Public repo: github.com/ZenithGenius/genius-desktop. Site: zenithgenius.github.io/genius-desktop (GitHub Pages from `docs/` on `main`; every push to `main` deploys it).

## Map

- `install.sh`: the only entry point. Layers: terminal (always), desktop (auto when GNOME exists, `--no-desktop` skips), boot (`--boot`, system-wide). `--dry-run` must stay side-effect free.
- `home/`: files copied into `$HOME` by the terminal layer (`home/.config/genius-desktop/genius.zsh` is the shell layer, sourced from `~/.zshrc`).
- `desktop/`: files copied into `$HOME` by the desktop layer (Conky, Burn My Windows profiles, sounds, cube sky box).
- `system/`: boot assets (Plymouth theme, GRUB theme, login wallpaper). Third-party, see `CREDITS.md`.
- `docs/`: GitHub Page (`index.html`) and README media (`docs/media/`).
- `CREDITS.md`: author, source and license of every asset. Update it when adding any third-party file.

## Rules

- No em dash in any text. One list item per line.
- No personal data: no local paths, emails or hostnames of the owner's machine. Commits use the GitHub noreply address.
- Every installer step must be idempotent and safe to re-run; replaced files get a `.bak-genius-DATE` copy.
- Test on the Kali lab VMs (srv, cli) before pushing installer changes: snapshot `pre-genius`, never touch snapshot `0-propre`. The Master-SSI-SJ agent drives the VMs.
- Media are rendered with Remotion from a separate local project (not in this repo).
