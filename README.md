# BartyCrouch

BartyCrouch can **search a Storyboard file for localizable strings** and **update your existing localization `.strings` incrementally** by adding new keys, keeping your existing translations and deleting only the ones that are no longer used. BartyCrouch even **keeps changes to your translation comments** given they are enclosed like `/* comment to keep */` and don't span multiple lines.


## Installation

Install Homebrew first if you don't have it already (more about Homebrew [here](http://brew.sh)):
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then simply run
```
brew install Flinesoft/BartyCrouch/formula
```
to install BartyCrouch.


## Usage

Before using BartyCrouch please **make sure you have committed your code**.

### Commands Overview

The command to be called in order to run BartyCrouch is named `bartycrouch`. `bartycrouch` accepts one of the following two combinations of commands:

1. Input-Storyboard and Output-Strings-Files
2. Input-Storyboard and Output-All-Languages

### Input-Storyboard

You can specify the input storyboard file using `--input-storyboard "path/to/my.storyboard"` or `-in "path/to/my.storyboard"` using the shorthand syntax.

### Output-Strings-Files

You can pass a list of `strings` files to be incrementally updated using  `--output-strings-files "path/to/en.strings,path/to/de.strings"` or `-out "path/to/en.strings,path/to/de.strings"` using the shorthand syntax.

### Output-All-Languages

If you use base internationalization (recommended) you can also let BartyCrouch find and update all `.strings` files automatically by passing `--output-all-languages` or `-all` using the shorthand syntax.

### Build Script

You may want to **update your `.strings` files on each build automatically** what you can easily do by adding a run script to your target in Xcode. In order to do this select your target in Xcode, choose the `Build Phases` tab and click the + button on the top left corner of that pane. Select `New Run Script Phase` and copy the following into the text box below the `Shell: /bin/sh` of your new run script phase:

```
// TODO: not yet documented
```

Now place the relative path(s) of your Storyboard(s) to translate into the `storyboards` array and you're good to go. Xcode will now run BartyCrouch each time you build your project and update your `.strings` files accordingly.

*Note: Please make sure you commit your code using source control regularly when using the build script method.*


## Contributing

Contributions are welcome. Please just open an Issue on GitHub to discuss a point or request a feature there or send a Pull Request with your suggestion. Please also make sure to write tests for your changes in order to make sure they don't break in the future.


## License
This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
