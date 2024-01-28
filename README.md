# Dotfiles
Heavily inspired by [Luke Smith's Voidrice](https://github.com/LukeSmithxyz/voidrice).

#### What i have in ~/.config 
- [Neovim](https://github.com/neovim/neovim)
    - It's just an [NvChad](https://github.com/NvChad/NvChad) with some custom settings
- [lf](https://github.com/gokcehan/lf) (File manager)
    - Custom `lfrc` with all necessary functions:
        - Create tar.gz or zip archive
        - Extract to the current or a new directory (work on all selected files)
        - Chmod (work on all selected files)
        - Bulk rename (copied from Luke's lfrc)  
        - Drag-and-drop (using [blobdrop](https://github.com/vimpostor/blobdrop))
        - Create symlink (work on all selected files)
        - Follow symlink
        - And other stuff
    - Previewer script with image support (ueberzug/kitty/chafa)
- zsh
    - No oh-my-zsh bloat, only a few plugins:
        - [p10k](https://github.com/zsh-users/zsh-autosuggestions) prompt
        - [autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
        - [history search](https://github.com/zsh-users/zsh-history-substring-search)
        - [syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- Bookmarks/shortcuts
    - Configured in `~/.config/shell/bm-files` and `~/.config/shell/bm-dirs` (run `shortcuts` after editing those)
    - Works in neovim, lf, and zsh
- [HOME directory cleanup](https://wiki.archlinux.org/title/XDG_Base_Directory)
    - Most of the configs are now in `~/.config`
    - Changed paths are in `~/.config/shell/profile`

## Install script
Just run `install.sh --help` to see available options. 

**All affected files will be backed up**

