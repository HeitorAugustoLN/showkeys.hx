# showkeys.hx

A Helix plugin to display pressed keys on screen.

[showkeys.webm](https://github.com/user-attachments/assets/03c62b77-2251-4771-88cd-d754521d5a6a)

## Usage

`:showkeys-toggle` to enable/disable.

## Installation

Follow the instructions [here](https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md) to install Helix on the plugin branch.

Then, install the plugin with:

```sh
forge pkg install --git https://github.com/HeitorAugustoLN/showkeys.hx.git
```

Once installed, you can add the following to `init.scm` in your Helix config directory:

```scheme
(require "showkeys/showkeys.scm")
```

## Limitations

Due to the way the Helix plugin system handles events, this plugin does not capture or display keys pressed while in command mode (e.g., after pressing `:`). It works correctly in other modes like normal and insert mode.
