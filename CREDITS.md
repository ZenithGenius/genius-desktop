# Credits and licenses

Everything the installer needs ships in this repository. Each third-party piece is listed below with its author, its source and the license it is used under. The scripts and configs written for this project are MIT (see `LICENSE`).

## Artwork and footage

| Asset | Where it is used | Author and source | License |
|---|---|---|---|
| "Hacker attack mask binary" illustration (image 7759727) | GRUB background, login wallpaper, boot splash poster | Gerd Altmann ([geralt on Pixabay](https://pixabay.com/users/geralt-9301/)), [image page](https://pixabay.com/illustrations/hacker-attack-mask-binary-one-7759727/) | [Pixabay Content License](https://pixabay.com/service/license-summary/) |
| "Long haired hacker wearing anonymous face mask in front of computer screens" (clip 50745) | Boot splash frames | [Mixkit](https://mixkit.co/free-stock-video/long-haired-hacker-wearing-anonymous-face-mask-in-front-of-50745/) | [Mixkit Stock Video Free License](https://mixkit.co/license/#videoFree) |
| Cross HUD reticle frames (`hud-*.png`) | Boot splash | Aditya Shakya ([adi1090x/plymouth-themes](https://github.com/adi1090x/plymouth-themes)) | GPL-3.0, full text in `system/plymouth/LICENSE-cross_hud` |
| Noto Sans Mono (`mono16.pf2`, `mono22.pf2`) | GRUB menu font | The Noto Project Authors, Google | SIL Open Font License 1.1, full text in `system/grub/OFL.txt` |

How these are used, and why it fits each license:

- The Pixabay illustration and the Mixkit clip are not redistributed as raw files. They are cropped, color graded to the steel palette, combined with scanlines, typed text and a HUD, and shipped only as parts of a boot and login theme. Both licenses allow modified use inside a larger work and forbid reselling or redistributing the original file on its own.
- Neither Pixabay nor Mixkit requires attribution. It is given here anyway.
- The `system/plymouth` folder includes GPL-3.0 frames, so that folder as a whole is distributed under GPL-3.0.
- Anyone reusing the theme images outside this project should go back to the original pages above and check the current terms.

## Made for this project

These were created for genius-desktop and are MIT like the rest of the code:

- the "Anonymous" sound theme (synthesized with ffmpeg tone generators)
- the Desktop Cube nebula sky box (generated)
- the boot splash script, the GRUB `theme.txt` and the selection bar images
- the Burn My Windows profiles, Conky HUD, tmux theme, starship, fastfetch, btop, cava, bat, yazi, lazygit, glow and tealdeer color configs
- the `lockscreen`, `starfield`, `mission`, `cava-idle`, `chat-index`, `genius-banner` and `genius-motd` scripts
- the README and site media (rendered with Remotion from recordings of these tools)

## Software installed or configured, not shipped

The installer gets these from your distribution, extensions.gnome.org or the project's own releases. Their code is not part of this repository.

| Project | Author | License |
|---|---|---|
| [Papirus icon theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) (the cyan folder variant is built from it on your machine) | Papirus Development Team | GPL-3.0 |
| [Bibata cursor](https://github.com/ful1e5/Bibata_Cursor) | Abdulkaiz Khatri (ful1e5) | GPL-3.0 |
| [Desktop Cube](https://github.com/Schneegans/Desktop-Cube) | Simon Schneegans | GPL-3.0 |
| [Burn My Windows](https://github.com/Schneegans/Burn-My-Windows) | Simon Schneegans | GPL-3.0 |
| [Coverflow Alt-Tab](https://github.com/dsheeler/CoverflowAltTab) | dsheeler and contributors | GPL-3.0 |
| [Vitals](https://github.com/corecoding/Vitals) | corecoding | GPL-2.0 |
| [gse-gdm-extension](https://github.com/pratap-panabaka/gse-gdm-extension) | Pratap Panabaka | GPL-3.0 |
| [starship](https://starship.rs) | Starship contributors | ISC |
| [eza](https://github.com/eza-community/eza) | eza community | EUPL-1.2 |
| [bat](https://github.com/sharkdp/bat) | David Peter | MIT / Apache-2.0 |
| [fzf](https://github.com/junegunn/fzf) | Junegunn Choi | MIT |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Ajeet D'Souza | MIT |
| [yazi](https://github.com/sxyazi/yazi) | sxyazi | MIT |
| [lazygit](https://github.com/jesseduffield/lazygit) | Jesse Duffield | MIT |
| [glow](https://github.com/charmbracelet/glow) | Charm | MIT |
| [btop](https://github.com/aristocratos/btop) | Aristocratos | Apache-2.0 |
| [cava](https://github.com/karlstav/cava) | Karl Stavestrand | MIT |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | fastfetch contributors | MIT |
| [tealdeer](https://github.com/tealdeer-rs/tealdeer) | tealdeer contributors | MIT / Apache-2.0 |
| [asciinema](https://asciinema.org) | asciinema contributors | GPL-3.0 |
| [cmatrix](https://github.com/abishekvashok/cmatrix) | Chris Allegretta, Abishek V Ashok | GPL-3.0 |
| [pipes.sh](https://github.com/pipeseroni/pipes.sh) | pipeseroni | MIT |
| [Conky](https://github.com/brndnmtthws/conky) | Brenden Matthews and contributors | GPL-3.0 |
| [Plymouth](https://gitlab.freedesktop.org/plymouth/plymouth) | freedesktop.org | GPL-2.0 |
| [Ghostty](https://ghostty.org) | Mitchell Hashimoto and contributors | MIT |
| [tmux](https://github.com/tmux/tmux), [zsh](https://www.zsh.org) | their projects | ISC, MIT-style |
