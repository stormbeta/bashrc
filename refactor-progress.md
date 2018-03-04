# Refactor 2018

This was originally inherited from Seth Goings and Doug Borg, and could really use some substantial refactoring.

Major issues

### Incompatible with zsh

With the early signs of RSI I'm trying to deal with, I need greater and easier customization of the shell. Zsh offers that, but isn't quite compatible with a lot of my current config.

### Lots of dead code

There's a lot of logic in here that I've never used, or is significantly over-engineered for my needs

### Shell prompt is hacky

While portable, my shell prompt is a generated file from vim-promptline I've hacked up, making it very difficult to extend or customize further

# Progress


