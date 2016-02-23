<p align="center">
    <img src="https://raw.githubusercontent.com/Flinesoft/BartyCrouch/develop/Logo.png"
      width=600 height=167>
</p>

<p align="center">
    <a href="https://github.com/Flinesoft/BartyCrouch/tags">
        <img src="https://img.shields.io/github/tag/Flinesoft/BartyCrouch.svg"
             alt="GitHub tag">
    </a>
    <a href="#">
        <img src="https://img.shields.io/badge/Swift-2.1-DD563C.svg"
             alt="Swift version">
    </a>
    <a href="https://github.com/Flinesoft/BartyCrouch/blob/develop/LICENSE.md">
        <img src="https://img.shields.io/github/license/Flinesoft/BartyCrouch.svg"
              alt="GitHub license">
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

### Complete Examples (TL;DR)

With BartyCrouch you can run commands like these:

``` shell
# Incrementally update English strings of Main.storyboard
bartycrouch -i "path/Base.lproj/Main.storyboard" -o "path/en.lproj/Main.strings"

# Incrementally update English and German strings of Main.storyboard
bartycrouch -i "path/Base.lproj/Main.storyboard" -o "path/en.lproj/Main.strings" "path/de.lproj/Main.strings"

# Incrementally update all languages of Main.storyboard
bartycrouch -i "path/Base.lproj/Main.storyboard" -a
```

Make your life easier by using the **build script method** described [below](#build-script).

### Commands Overview

The `bartycrouch` main command accepts one of the following two combinations of arguments:

1. Input and Output
2. Input and Auto

#### Input (aka `-i`)

You can specify the input Storyboard or XIB file using `-i "path/to/my.storyboard"` (`-i` is short `--input`).

#### Output (aka `-o`)

You can pass a list of `.strings` files to be incrementally updated using  `-o "path/to/en.strings" "path/to/de.strings"` (`-o` is short for `--output`).

#### Auto (aka `-a`)

If you use base internationalization (recommended) you can also let BartyCrouch find and update all `.strings` files automatically by passing `--auto` or `-a` using the shorthand syntax.


### Build Script

You may want to **update your `.strings` files on each build automatically** what you can easily do by adding a run script to your target in Xcode. In order to do this select your target in Xcode, choose the `Build Phases` tab and click the + button on the top left corner of that pane. Select `New Run Script Phase` and copy the following into the text box below the `Shell: /bin/sh` of your new run script phase:

``` shell
if which bartycrouch > /dev/null; then
    # Set path to base internationalized Storyboard/XIB files
    BASE_PATH="$PROJECT_DIR/Sources/User Interface/Base.lproj"

    # Incrementally update all Storyboards/XIBs strings files
    bartycrouch -i "$BASE_PATH/Main.storyboard" -a
    bartycrouch -i "$BASE_PATH/LaunchScreen.storyboard" -a
    bartycrouch -i "$BASE_PATH/CustomView.xib" -a
else
    echo "BartyCrouch not installed, download it from https://github.com/Flinesoft/BartyCrouch"
fi
```

<img src="Build-Script-Example.png">

Now update the `BASE_PATH` to point to your Base.lproj directory, add a `bartycrouch -i ... -a` for each of your base internationalized Storyboards/XIBs (if any) and you're good to go. Xcode will now run BartyCrouch each time you build your project and update your `.strings` files accordingly.

*Note: Please make sure you commit your code using source control regularly when using the build script method.*

### Exclude specific views from localization

Sometimes you may want to **ignore some specific views** containing localizable texts e.g. because **their values are set programmatically**.
For these cases you can simply include `#bartycrouch-ignore!` or the shorthand `#bc-ignore!` into your value within your base localized Storyboard/XIB file.
This will tell BartyCrouch to ignore this specific view when updating your `.strings` files.

Here's an example of how a base localized view in a XIB file with partly ignored strings might look like:

<img src="Exclusion-Example.png">

## Migration Guides

This project follows [Semantic Versioning](http://semver.org). Please follow the appropriate guide below when **upgrading to a new major version** of BartyCrouch (e.g. 0.3 -> 1.0).

### Upgrade from 0.x to 1.x

- `--input-storyboard` and `-in` were **renamed** to `--input` and `-i`
- `--output-strings-files` and `-out` were **renamed** to `--output` and `-o`
- Multiple paths passed to `-output` are now **separated by whitespace instead of comma**
  - e.g. `-out "path/one,path/two"` should now be `-o "path/one" "path/two"`
- `--output-all-languages` and `-all` were **renamed** to `--auto` and `-a`


## Contributing

Contributions are welcome. Please just open an Issue on GitHub to discuss a point or request a feature there or send a Pull Request with your suggestion. Please also make sure to write tests for your changes in order to make sure they don't break in the future. Please note that there is a framework target within the project alongside the command line utility target to make testing easier.


## License
This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
