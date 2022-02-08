bashrc
======

Personal bash/cli config. These dotfiles are set up to be linked in with Homesick.

## Highlights:

* Sets many useful bash options such as globstar matching, spellcheck, and faster completion
* Transparent ssh agent setup, especially for macOS (now supports Monterey)
* Unlimited history with synchronization across local shell instances
* Fancy prompt, pure bash to avoid dependencies
* terminfo settings to support italics
* typing a partial command and hitting up arrow matches history with the same prefix
* fasd/fzf helpers for jumping to files and directories with fuzzy matching

Misc
----

> `HOME/.editorconfig`

Sets global defaults for project whitespacing in most editors
http://editorconfig.org/

> `HOME/.bashrc.d/prompt.sh`

Pure bash fancy shell prompt, generated by vim-promptline and then customized
Color scheme intended to look readable under both light and dark colorschemes (specifically solarized)

* (orange) project version of node.js, ruby, or python virtualenv where applicable
* (blue) hostname
* current path (compacted)
* current git branch
* exit code of last command if non-zero, in red

> `HOME/.dircolors`

Standardize directory colors for `ls` across systems

> `HOME/.inputrc`

Readline customizations. Mainly used to enable history prefix matching on up-arrow.
E.g. if I type a partial command and press up arrow, it will only match previous commands with the same prefix. It also makes completion case-insensitive.


### `HOME/.bashrc.d`

* completion: load various completion scripts (intended to be loaded first)
* topics: general config by category
* platforms: platform/os specific config

### `HOME/bin`

Executable script wrappers, especially if not written by me.

TODO: Most of these are probably not relevant anymore, except for `gw` and `mw`

> `gw`

"gdub", a Gradle wrapper wrapper.
Call gradle via the wrapper from any folder in a project and have it do what you expect

Credit: https://github.com/dougborg/gdub

> `mw`

Maven equivalent to `gw`, and inspired by it. Requires your project to be using the maven wrapper,
which was also inspired by gradlew.
