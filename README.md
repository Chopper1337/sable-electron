# Sable Desktop (Electron Version)

This is a completely unofficial wrapper around [Sable](https://sable.moe) made in Electron,
because Tauri works poorly for me, especially on NixOS.

I don't know what I'm doing, beware.

# Additional Features

- Tray icon shows whether there are notifications or not
- QuickCSS support, look in $HOME/.config/sable-electron/quickcss.css

# Installing

## From the AUR (Arch Linux)

A `-git` PKGBUILD is provided in [`aur/`](./aur). Using an AUR helper:

```sh
yay -S sable-electron-git
# or: paru -S sable-electron-git
```

Or manually with `makepkg`:

```sh
git clone https://aur.archlinux.org/sable-electron-git.git
cd sable-electron-git
makepkg -si
```

This builds from source and installs `/usr/bin/sable-electron`, a desktop
entry, and the icon. You can pass extra Electron/Chromium flags by adding them
to `$XDG_CONFIG_HOME/sable-flags.conf` (one flag per line).

## From a packaged build (any Linux distro)

Build the distributable packages yourself (see [Building](#building)) and
install the one matching your distro from `dist/`:

```sh
# Debian/Ubuntu
sudo apt install ./dist/*.deb

# Fedora/RHEL
sudo dnf install ./dist/*.rpm

# Any distro — no install needed, just run the AppImage
chmod +x ./dist/*.AppImage
./dist/sable-electron-*.AppImage
```

# Building

## Prerequisites

- [Node.js](https://nodejs.org/) 22+
- [pnpm](https://pnpm.io/) 10.20.0 (the version pinned in `packageManager`;
  `corepack enable` will fetch it automatically)

## Steps

```sh
# 1. Install dependencies
pnpm install

# 2a. Run in development
pnpm dev

# 2b. Build an unpacked app into dist/linux-unpacked (fastest, for testing)
pnpm run build:unpack

# 2c. Build distributable packages (AppImage, deb, rpm) into dist/
pnpm run build:linux
```

`build:win` and `build:mac` are also available for building Windows and macOS
targets respectively.

# Credits

[Vesktop](https://github.com/Vencord/Vesktop) was used heavily as a reference
[Moonlight](https://github.com/moonlight-mod/moonlight) was also used heavily as a reference
