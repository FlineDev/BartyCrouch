<p align="center">
    <img src="https://raw.githubusercontent.com/Flinesoft/BartyCrouch/stable/Logo.png"
      width=600 height=167>
</p>

<p align="center">
    <a href="https://github.com/Flinesoft/BartyCrouch/releases">
        <img src="https://img.shields.io/badge/Version-2.0.0-blue.svg"
             alt="Version: 2.0.0">
    </a>
    <a href="#">
        <img src="https://img.shields.io/badge/Swift-2.2-DD563C.svg"
             alt="Swift: 2.2">
    </a>
    <a href="https://github.com/Flinesoft/BartyCrouch/blob/stable/LICENSE.md">
        <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg"
              alt="License: MIT">
    </a>
</p>


# BartyCrouch

BartyCrouch can **search a Storyboard/XIB file for localizable strings** and **update your existing localization `.strings` incrementally** by adding new keys, keeping your existing translations and deleting only the ones that are no longer used. BartyCrouch even **updates your translation comments** with updated Base values if their structure was not changed from the Xcode defaults and will **keep changes to your translation comments** if started by a `/*!` (recommended) or the default structure was changed in another way.

Additionally BartyCrouch can also **automatically translate existing `.strings` files to languages you don't speak** using the Microsoft Translator API. You can exactly **choose the languages to auto-translate** or simply all and BartyCrouch will **keep all existing translations** by default.


## Requirements

- Xcode 7.3+ and Swift 2.2+
- Xcode Command Line Tools (see [here](http://stackoverflow.com/a/9329325/3451975) for installation instructions)

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

To **update** to the newest version of BartyCrouch when you have an old version already installed run:
``` shell
brew update
brew upgrade flinesoft/bartycrouch/bartycrouch
```

## Usage

Before using BartyCrouch please **make sure you have committed your code**.

### Complete Examples (TL;DR)

With BartyCrouch you can run commands like these:

``` shell
# Incrementally update English, Simplified Chinese and Brazilian Portuguese strings of Main.storyboard
bartycrouch -i "path/Base.lproj/Main.storyboard" -o en zh-Hans pt-BR

# Incrementally update all languages of all Storyboard/XIB files
bartycrouch -s "/absolute/path/to/project"

# Machine-translate all empty values of all supported languages with English as source
bartycrouch -t "{ id: ID }|{ secret: SECRET }" -s "/absolute/path/to/project" -l en

# Force-translates all values (overriding existing ones) of all languages except German with English as source
bartycrouch -f -t "{ id: ID }|{ secret: SECRET }" -i "en.lproj/Localizable.strings" -e "de.lproj/Localizable.strings"
```

Also you can make your life a lot easier by using the **build script method** described [below](#build-script).

### Commands Overview

The `bartycrouch` main command accepts one of the following combinations of arguments:

1. Automatic update input and output search (all localized Storyboards/XIBs)
2. Update Input and Output/Except
3. Automatic translation input and output search (all sets of `.strings` files)
4. Translation with Input and Output/Except

You can also additionally specify Force and/or Verbose on each command.

#### Search (aka `-s`)

If you want BartyCrouch to **search for all localized Storyboards/XIBs** (those in Base.lproj folders) or **search for all Strings files** given a source language and also want BartyCrouch to find the respective output files, then simply declare the BartyCrouch command with `-s` followed by an absolute path like `-s "/absolute/path/to/project"` (`-s` is short for `--search`).

*Note that when using this with the translate option (`-t`) then you will also need to specify the locale option (`-l`).*

#### Input (aka `-i`)

You can specify a single input Storyboard, XIB or Strings file explicitly using `-i "path/to/my.storyboard"` (`-i` is short for `--input`).

#### Output (aka `-o`)

You can pass a whitespace separated list of `.strings` files to be incrementally updated / translated using  `-o "path/to/en.strings" "path/to/de.strings"` (`-o` is short for `--output`). You can also specify a list of locales only and let BartyCrouch find the correct paths automatically e.g. via `-o en de zh-Hans pt-BR`.

#### Except (aka `-e`)

You may be supporting a bunch of languages and handle a few of them differently than the rest. In these cases you can specify a list of paths to exclude from automatic Strings file search via `-e "path/to/your.file"` (`-e` is short for `--except`).

#### Translate (aka `-t`)

Sometimes it makes sense to **start with machine translated strings** and let humans **improve them later on**. This can save time for translators and may even be a viable solution for some languages you wouldn't have localized to otherwise.

You can do this easily with BartyCrouch: Simply run the `bartycrouch` command with an input `.strings` file as input instead of a Storyboard/XIB file and add `-t "{ id: YOUR_ID }|{ secret: YOUR_SECRET }"` (`-t` is short for `--translate`). You can also use the `-s` option with a base directory to search for with a source locale provided via `-l` (short for `--locale`) like this: `-t "{ id: YOUR_ID }|{ secret: YOUR_SECRET }" -s "/absolute/path/to/project" -l en`. This example would search for all Strings files and translate all missing keys using English as the source language.

In order to use the Microsoft Translator API you need to **register [here](https://datamarket.azure.com/dataset/bing/microsofttranslator)** (the free tier allows for 2 million translations/month). Then you can **add a client [here](https://datamarket.azure.com/developer/applications)** which will provide you the `id` and `secret` credentials needed for this feature.

#### Force (aka `-f`)

BartyCrouch keeps existing translations by default. In case you don't want to keep them but want BartyCrouch to overwrite all existing translations then you can enforce this by passing the `-f` option (`-f` is short for `--force`).

#### Verbose (aka `-v`)

To see more about what BartyCrouch is doing you can also run all commands with the `-v` flag (`-v` is short for `--verbose`). This will print more details about the current work in progress.

#### Default to Base (aka `-b`)

To use the Base localization values when adding new keys (instead of empty values) simply add the option `-b` (`-b` is short for `--default-to-base`). Note that this option will have no effects if used on the translate command.

### Build Script

You may want to **update your `.strings` files on each build automatically** what you can easily do by adding a run script to your target in Xcode. In order to do this select your target in Xcode, choose the `Build Phases` tab and click the + button on the top left corner of that pane. Select `New Run Script Phase` and copy the following into the text box below the `Shell: /bin/sh` of your new run script phase:

```shell
if which bartycrouch > /dev/null; then
    # Incrementally update all Storyboards/XIBs strings files
    bartycrouch -s "$PROJECT_DIR"
else
    echo "warning: BartyCrouch not installed, download it from https://github.com/Flinesoft/BartyCrouch"
fi
```

<img src="Build-Script-Example.png">

*Note: Please make sure you commit your code using source control regularly when using the build script method.*

If you want to use the **machine translation functionality** in addition then simply use the following build script instead:

```shell
if which bartycrouch > /dev/null; then
    # Incrementally update all Storyboards/XIBs strings files
    bartycrouch -s "$PROJECT_DIR"

    # Set Microsoft Translator API credentials
    CREDS="{ id: YOUR_ID }|{ secret: YOUR_SECRET }"

    # Machine-translate empty language values for all languages
    bartycrouch -t "$CREDS" -s "$PROJECT_DIR" -l en
else
    echo "warning: BartyCrouch not installed, download it from https://github.com/Flinesoft/BartyCrouch"
fi
```

### Exclude specific views from localization

Sometimes you may want to **ignore some specific views** containing localizable texts e.g. because **their values are set programmatically**.
For these cases you can simply include `#bartycrouch-ignore!` or the shorthand `#bc-ignore!` into your value within your base localized Storyboard/XIB file.
This will tell BartyCrouch to ignore this specific view when updating your `.strings` files.

Here's an example of how a base localized view in a XIB file with partly ignored strings might look like:

<img src="Exclusion-Example.png">

## Migration Guides

This project follows [Semantic Versioning](http://semver.org). Please follow the appropriate guide below when **upgrading to a new major version** of BartyCrouch (e.g. 1.5 -> 2.0).

### Upgrade from 1.x to 2.x

- Change command structure `bartycrouch "$BASE_PATH" -a` to `bartycrouch -s "$BASE_PATH"`
- Remove `-c` option if you were using it, BartyCrouch 2.x creates missing keys by default
- Use the new `-t` `-s` `-l` options instead of adding all Strings files manually, e.g.:

Simplify this build script code

```shell
bartycrouch -t $CREDS -i "$EN_PATH/Localizable.strings" -a -c
bartycrouch -t $CREDS -i "$EN_PATH/Main.strings" -a
bartycrouch -t $CREDS -i "$EN_PATH/LaunchScreen.strings" -a
bartycrouch -t $CREDS -i "$EN_PATH/CustomView.strings" -a
```

by replacing it with this:

```shell
bartycrouch -t "$CREDS" -s "$PROJECT_DIR" -l en
```


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
