# termcraft
Run bash commands from minecraft.

## How to install

This works on the `tmux` terminal multiplexer.

To make this work, simply activate a new tmux session on your server like so:

```
tmux new -s steve
```

`steve` is now the name of this session.

Then launch your server within the `tmux` session.

Make sure to change the config variables at the top of `termcraft.sh` if need be.

A default `termcraft.conf` is provided. Change as you please.

This work is licensed under the GPLv3. Sharing is caring.
