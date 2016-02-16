<p align="center">
    <img src="https://raw.githubusercontent.com/Flinesoft/BartyCrouch/develop/Logo.png"
      width=600 height=167>
</p>

<p align="center">
    <a href="#">
    <img src="https://img.shields.io/badge/Swift-2.1-DD563C.svg"
       alt="Swift: 2.1">
    </a>
    <a href="https://github.com/Flinesoft/BartyCrouch/blob/develop/LICENSE.md">
        <img src="https://img.shields.io/badge/license-MIT-blue.svg"
             alt="license: MIT">
    </a>
</p>


# BartyCrouch

BartyCrouch can **search a Storyboard/xib file for localizable strings** and **update your existing localization `.strings` incrementally** by adding new keys, keeping your existing translations and deleting only the ones that are no longer used. BartyCrouch even **keeps changes to your translation comments** given they are enclosed like `/* comment to keep */` and don't span multiple lines.


## Installation

Install Homebrew first if you don't have it already (more about Homebrew [here](http://brew.sh)):
``` shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then simply run the commands
``` shell
brew tap flinesoft/bartycrouch
brew install flinesoft/bartycrouch/bartycrouch
```
to install BartyCrouch.


## Usage

Before using BartyCrouch please **make sure you have committed your code**.

### Command Overview

The `bartycrouch` main command accepts one of the following two combinations of arguments:

1. Input-Storyboard and Output-Strings-Files
2. Input-Storyboard and Output-All-Languages

#### Input-Storyboard (aka `-in`)

You can specify the input storyboard file using `--input-storyboard "path/to/my.storyboard"` or `-in "path/to/my.storyboard"` using the shorthand syntax.

#### Output-Strings-Files (aka `-out`)

You can pass a list of `strings` files to be incrementally updated using  `--output-strings-files "path/to/en.strings,path/to/de.strings"` or `-out "path/to/en.strings,path/to/de.strings"` using the shorthand syntax.

#### Output-All-Languages (aka `-all`)

If you use base internationalization (recommended) you can also let BartyCrouch find and update all `.strings` files automatically by passing `--output-all-languages` or `-all` using the shorthand syntax.

### Complete Examples

All of the above put together, you can run the following (replace `path`):

``` shell
bartycrouch -in "path/Base.lproj/Main.storyboard" -out "path/en.lproj/Main.strings"
bartycrouch -in "path/Base.lproj/Main.storyboard" -out "path/en.lproj/Main.strings,path/de.lproj/Main.strings"
bartycrouch -in "path/Base.lproj/Main.storyboard" -all
```

### Build Script

You may want to **update your `.strings` files on each build automatically** what you can easily do by adding a run script to your target in Xcode. In order to do this select your target in Xcode, choose the `Build Phases` tab and click the + button on the top left corner of that pane. Select `New Run Script Phase` and copy the following into the text box below the `Shell: /bin/sh` of your new run script phase:

``` shell
if which bartycrouch > /dev/null; then
    # Set path to base internationalized storyboards
    BASE_PATH="$PROJECT_DIR/Sources/User Interface/Base.lproj"

    # Incrementally update all storyboards strings files
    bartycrouch -in "$BASE_PATH/Main.storyboard" -all
    bartycrouch -in "$BASE_PATH/LaunchScreen.storyboard" -all
    bartycrouch -in "$BASE_PATH/CustomView.xib" -all
else
    echo "BartyCrouch not installed, download it from https://github.com/Flinesoft/BartyCrouch"
fi
```

Add a `bartycrouch -in ... -all` line for each of your base internationalized storyboards/xibs and you're good to go. Xcode will now run BartyCrouch each time you build your project and update your `.strings` files accordingly.

*Note: Please make sure you commit your code using source control regularly when using the build script method.*


## Contributing

Contributions are welcome. Please just open an Issue on GitHub to discuss a point or request a feature there or send a Pull Request with your suggestion. Please also make sure to write tests for your changes in order to make sure they don't break in the future. Please note that there is a framework target within the project alongside the command line utility target to make testing easier.


## License
This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
