# Journal

## 2026-10-30

- Prompt top line no longer lost on window resize or Ctrl+L: starship split into `profiles.top` (printed by a zsh precmd as plain output) and a one-line prompt `└─❯`. Verified in a pty with a SIGWINCH resize.
- Ghostty opens at 110x32 so fastfetch is not truncated (was 88 columns).

## 2026-10-29

- apt-get update failure now stops with the Kali keyring fix; README troubleshooting entry added.

## 2026-10-28

- Built the repo from the owner's customized Ubuntu desktop: installer, configs, themes, README, GitHub Page, CREDITS.md.
- Tested on Kali VMs srv and cli via Master-SSI-SJ. Fixes from testing: locale-safe package check, idempotent yazi and extension steps, GRUB drop-in renamed `zz-genius.cfg` to sort after `kali-themes.cfg`, GRUB_BACKGROUND set, curl retries.
- Published public repo and Pages (commits b642a57 to c1d2f3a).
