# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/).

<details>
<summary>Formatting Rules for Entries</summary>
Each entry should use the following format:

```markdown
- Summary of what was changed in a single line using past tense & followed by two whitespaces.  
  Issue: [#0](https://github.com/FlineDev/BartyCrouch/issues/0) | PR: [#0](https://github.com/FlineDev/BartyCrouch/pull/0) | Author: [Cihat Gündüz](https://github.com/Jeehut)
```

Note that at the end of the summary line, you need to add two whitespaces (`  `) for correct rendering on GitHub.

If needed, pluralize to `Tasks`, `PRs` or `Authors` and list multiple entries separated by `, `. Also, remove entries not needed in the second line.
</details>

## [Unreleased]
### Added
- None.
### Changed
- None.
### Deprecated
- None.
### Removed
- None.
### Fixed
- None.
### Security
- None.

## [4.12.0] - 2022-09-25
### Changed
- Update SwiftSyntax dependency to Swift 5.7 to support Xcode 14.  
  Issues: [#201](https://github.com/FlineDev/BartyCrouch/issues/201), [#262](https://github.com/FlineDev/BartyCrouch/pull/262) | Author: [Texot](https://github.com/tete1030)

## [4.11.0] - 2022-05-27
### Added
- Adds new `separateWithEmptyLine` options to allow removing the empty line between Strings entries.  
  Issues: [#251](https://github.com/FlineDev/BartyCrouch/issues/251) | PR: [#254](https://github.com/FlineDev/BartyCrouch/pull/254) | Author: [Cihat Gündüz](https://github.com/Jeehut)  
### Fixed
- Fixed an issue where defaulting to Microsoft Translator no longer worked after starting to support DeepL as a translator, too.    
  Author: [Cihat Gündüz](https://github.com/Jeehut)  

## [4.10.2] - 2022-03-26
### Changed
- Update SwiftSyntax dependency to Swift 5.5 to support Xcode 13.  
  Issues: [#201](https://github.com/FlineDev/BartyCrouch/issues/201), [#249](https://github.com/FlineDev/BartyCrouch/issues/249) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [4.9.0] - 2022-01-21
### Added
- Added a new option `ignoreKeys` to provide custom alternatives to the default `bc-ignore` kind of keys if needed. New option defaults to `["#bartycrouch-ignore!", "#bc-ignore!", "#i!"]` if not specified otherwise.  
  PR: [#242](https://github.com/FlineDev/BartyCrouch/pull/242) | Author: [Cihat Gündüz](https://github.com/Jeehut)
- Added a new option `subpathsToIgnore` to provide subpaths to be ignored (with case-insensitive comparison) inside of the provided `paths`. New option defaults to `[".git", "carthage", "pods", "build", ".build", "docs"]` if not specified otherwise.  
  PR: [#242](https://github.com/FlineDev/BartyCrouch/pull/242) | Author: [Cihat Gündüz](https://github.com/Jeehut)
### Fixed
- Removed ignoring all `InfoPlist.strings` files by default. If you want this to actually be the case, just add `InfoPlist.strings` to the array in the new `subpathsToIgnore` option, e.g.: `subPathsToIgnore = [".git", "carthage", "pods", "build", ".build", "docs", "InfoPlist.strings"]`  
  PR: [#242](https://github.com/FlineDev/BartyCrouch/pull/242) | Author: [Cihat Gündüz](https://github.com/Jeehut)
- Less situations where the empty `tmpstring` folder continues to exist.  
  PR: [#238](https://github.com/FlineDev/BartyCrouch/pull/238) | Author: [Benjamin Erhart](https://github.com/tladesignz)
- Only apply ignores on subpaths of explicitly mentioned folders in `path` options, don't ignore any paths that are explicitly mentioned.  
  PR: [#240](https://github.com/FlineDev/BartyCrouch/pull/240) | Author: [Benjamin Erhart](https://github.com/tladesignz)

## [4.8.0] - 2021-10-10
### Changed
- Update SwiftSyntax dependency to Swift 5.5 to support Xcode 13.  
  Author: [Kevin](https://github.com/moogle19)

## [4.7.1] - 2021-08-26
### Fixed
- Fixed that DeepL translation doesn't work for Simplified Chinese.  
  PR: [#232](https://github.com/FlineDev/BartyCrouch/pull/232) | Author: [Manabu Nakazawa](https://github.com/mshibanami)

## [4.7.0] - 2021-07-31
### Added
- Add support for DeepL API Free  
  PR: [#230](https://github.com/FlineDev/BartyCrouch/pull/230) | Author: [Manabu Nakazawa](https://github.com/mshibanami)

## [4.6.0] - 2021-05-08
### Changed
- Updated swift-syntax to match Swift 5.4 to support Xcode 12.5.  
  Issues: [#222](https://github.com/FlineDev/BartyCrouch/issues/222) | PR: [#223](https://github.com/FlineDev/BartyCrouch/pull/223) | Author: [Matt Sanford](https://github.com/mzsanford)

## [4.5.0] - 2021-02-21
### Added
- Add support for DeepL API as an alternative for Microsoft Translator API.  
  PR: [#220](https://github.com/FlineDev/BartyCrouch/pull/220) | Author: [noppe](https://github.com/noppefoxwolf)

## [4.4.1] - 2021-01-16
### Fixed
- Fixed an issue with unmatching country code casing for Portuguese and Canadian French.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)

## [4.4.0] - 2021-01-16
### Changed
- Updated languages supported by Microsoft Translator – 17 more languages available now!  
  Issue: [#216](https://github.com/FlineDev/BartyCrouch/issues/216) | PR: [#219](https://github.com/FlineDev/BartyCrouch/pull/219) | Author: [Jamie Gough](https://github.com/jamiegough)
- BartyCrouch doesn't fail anymore when there's a language not supported by Microsoft Translator (yet) – it prints a warning instead.  
  Issue: [#215](https://github.com/FlineDev/BartyCrouch/issues/215) | PR: [#219](https://github.com/FlineDev/BartyCrouch/pull/219) | Author: [Jamie Gough](https://github.com/jamiegough)

## [4.3.2] - 2020-12-24
### Fixed
- Fixed an issue where BartyCrouch did not skip the directories ".git", "Carthage", "Pods", "build", ".build", "docs" anymore.  
  Issues: [#213](https://github.com/FlineDev/BartyCrouch/issues/213), [#2](https://github.com/FlineDev/BartyCrouch/issues/177) | PR: [#214](https://github.com/FlineDev/BartyCrouch/pull/214) | Author: [Bill Panagiotopoulos](https://github.com/billp)

## [4.3.1] - 2020-10-06
### Fixed
- Fix missing usage of `harmonizeWithSource` parameter for `normalize` task.  
  Issue: [#196](https://github.com/FlineDev/BartyCrouch/issues/196) | PR: [#182](https://github.com/FlineDev/BartyCrouch/pull/197) | Author: [Marco Pagliari](https://github.com/lechuckcaptain)

## [4.3.0] - 2020-09-28
### Changed
- Updated swift-syntax to match Swift 5.3.  
  Issues: [#199](https://github.com/FlineDev/BartyCrouch/issues/199), [#201](https://github.com/FlineDev/BartyCrouch/issues/201) | PR: [#204](https://github.com/FlineDev/BartyCrouch/pull/204) | Author: [w8wjb](https://github.com/w8wjb)

## [4.2.0] - 2020-04-24
### Added
- Added new `-p` / `--path` option to run BartyCrouch from a different path than current.  
  Issues: [#166](https://github.com/FlineDev/BartyCrouch/issues/166), [#177](https://github.com/FlineDev/BartyCrouch/issues/177) | PR: [#181](https://github.com/FlineDev/BartyCrouch/pull/181) | Author: [Cihat Gündüz](https://github.com/Jeehut)
### Removed
- Removed code magic that used the localization comment from Interface Builder files as a source for new translation values.  
  Issue: [#140](https://github.com/FlineDev/BartyCrouch/issues/140) | PR: [#182](https://github.com/FlineDev/BartyCrouch/pull/182) | Author: [Cihat Gündüz](https://github.com/Jeehut)
### Fixed
- Normalize sortByKeys no longer adds empty line to begining of .strings file.  
  Issue: [#178](https://github.com/FlineDev/BartyCrouch/issues/178) | PR: [#180](https://github.com/FlineDev/BartyCrouch/pull/180) | Author: [Patrick Wolowicz](https://github.com/hactar)

## [4.1.1] - 2020-04-16
### Fixed
- Fixed crashes in projects with large number of files by introducing new `plist` file based approach for passing arguments. See the new `--plist-arguments` option. Will be automatically turned on when needed (many files in project).  
  Issues: [#92](https://github.com/FlineDev/BartyCrouch/issues/92), [#99](https://github.com/FlineDev/BartyCrouch/issues/99) | PRs: [#150](https://github.com/FlineDev/BartyCrouch/pull/150), [#176](https://github.com/FlineDev/BartyCrouch/pull/176) | Authors: [Christos Koninis](https://github.com/csknns), [Cihat Gündüz](https://github.com/Jeehut)

## [4.1.0] - 2020-04-10
### Added
- Added support for specifying multiple paths for all `path` options.  
  Issue: [#155](https://github.com/FlineDev/BartyCrouch/issues/155) | PR: [#167](https://github.com/FlineDev/HandySwift/pull/167) | Author: [Frederick Pietschmann](https://github.com/fredpi)
### Changed
- Upgraded SwiftSyntax to Swift 5.2 version `0.50200.0`.  
  Issue: [#170](https://github.com/FlineDev/BartyCrouch/issues/170) | PRs: [#171](https://github.com/FlineDev/BartyCrouch/pull/171), [#172](https://github.com/FlineDev/BartyCrouch/pull/172), [#173](https://github.com/FlineDev/BartyCrouch/pull/173) | Authors: [Tomoya Hirano](https://github.com/noppefoxwolf), [Cihat Gündüz](https://github.com/Jeehut)
- Updated all dependencies to their latest versions to prevent warnings.  
  PR: [#172](https://github.com/FlineDev/BartyCrouch/pull/172) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [4.0.2] - 2019-05-13
### Fixed
- Make Code Transform, Normalize & Lint fast again (up to 50x faster). Fixes [#128](https://github.com/FlineDev/BartyCrouch/issues/128) by [Frederick Pietschmann](https://github.com/fredpi).

## [4.0.1] - 2019-03-26
### Added
- Support for Swift 5.0 and Xcode 10.2 command line tools. By [Cihat Gündüz](https://github.com/Dschee).
### Changed
- Don't rewrite files if they didn't change to improve performance. Via [#111](https://github.com/FlineDev/BartyCrouch/issues/120) by [Keith Bauer](https://github.com/OneSadCookie).
### Deprecated
- None.
### Removed
- Support for Swift 4.2 and Xcode <=10.1. If you need to run BartyCrouch with older Xcode versions and had a previous version of BartyCrouch installed, then simply switch to it via `brew switch bartycrouch 4.0.0`. By [Cihat Gündüz](https://github.com/Dschee).
### Fixed
- Turns off multiple key/value pairs warning by default. Fixes [#120](https://github.com/FlineDev/BartyCrouch/issues/120) via [#121](https://github.com/FlineDev/BartyCrouch/pull/121) by [Robert Baker](https://github.com/magneticrob).
### Security
- None.

## [4.0.0] - 2019-02-04
### Added
- Support for [installation](https://github.com/FlineDev/BartyCrouch#installation) via Mint (SwiftSPM based).
- Use [configuration file](https://github.com/FlineDev/BartyCrouch#configuration) instead of thousands of command line options.
- [Demo project based](https://github.com/FlineDev/BartyCrouch/tree/stable/Demo/Untouched) integration tests.
- Sophisticated [SwiftGen](https://github.com/SwiftGen/SwiftGen)-Integration (automatic static NSLocalizedString code replacement) via new `transform` option.
### Changed
- All subcommands except `lint` were bundled into the `update` subcommand.
- [Own client implementation](https://github.com/FlineDev/BartyCrouch/tree/stable/Sources/BartyCrouchTranslator) of updated Microsowft Translator API.
### Deprecated
- None.
### Removed
- The `--override-comments` (`-c`) option on the `code` subcommand is now always turned on, no need to configure.
- The `--extract-loc-strings` (`-e`) option on the `code` subcommand is now always turned on, no need to configure.
### Fixed
- More resilient search behavior (to fix issues such as #64, #87, #102, #105).
### Security
- None.

## [3.13.1] - 2018-07-26
### Added
- Added ability to ignore empty strings.
  via [#107](https://github.com/FlineDev/BartyCrouch/pull/107) by [Ludvig Eriksson](https://github.com/ludvigeriksson)
### Changed
- Restructure code for SPM compatibility.
- Introduce CHANGELOG.md, CONTRIBUTION.md and CODE_OF_CONDUCT.md
- Improve Installation section of README
### Deprecated
- None.
### Removed
- None.
### Fixed
- None.
### Security
- None.

## [3.13.0] - 2018-05-09
### Added
– Adds new sub command `lint` with multiple options.
For example you can now add this to your CI service:
```bash
bartycrouch lint -p "/path/to/code/files" -d -e
```
This will:
- [x] fail the CI if duplicate keys are found within the same file (`-d`)
- [x] fail the CI if empty values are found (`-e`)

## [3.12.0] - 2018-05-08
### Added
– Adds new sub command `normalize` with multiple options.
For example you can now add this to your build script:
```bash
bartycrouch normalize -p "/path/to/code/files" -l en -d -w -h -s
```
This will:
- [x] warn against duplicate keys or fix them if it can (`-d`)
- [x] warn against empty values (`-w`)
- [x] make sure your target languages have exactly the same keys as your source language (`-h`)
- [x] sort your keys except for those without translations (`-s`)

## [3.11.2] - 2018-04-16
### Fixed
- Fixed an issue which didn't run sorting keys when no translations were found
- Improved performance with many files

## [3.11.1] - 2018-03-12
### Fixed
- Fixes a bug related to the new `--custom-localizable-name` option.

## [3.11.0] - 2018-03-11
### Added
– Adds new option `--custom-localizable-name` for `code` subcommand

## [3.10.1] - 2018-03-08
### Fixed
- Reverts [#67](https://github.com/FlineDev/BartyCrouch/issues/67) to fix [#11](https://github.com/FlineDev/BartyCrouch/issues/11) and [#88](https://github.com/FlineDev/BartyCrouch/issues/88).

## [3.10.0] - 2018-02-05
### Added
- Add support for Swift Package Manager + fixed some issues.
  Thanks to @mshibanami & @ClementPadovani.

## [3.9.2] - 2018-01-09
### Fixed
Fixes [#72](https://github.com/FlineDev/BartyCrouch/issues/72).

## [3.9.1] - 2017-12-11
### Fixed
Fixes [#65](https://github.com/FlineDev/BartyCrouch/issues/65).

## [3.9.0] - 2017-09-26
### Changed
- Update to Swift 4 & Xcode 9
### Fixed
Fixes [#66](https://github.com/FlineDev/BartyCrouch/issues/66).

## [3.8.1] - 2017-08-02
### Fixed
Fixes [#55](https://github.com/FlineDev/BartyCrouch/issues/55), [#60](https://github.com/FlineDev/BartyCrouch/issues/60) and [#63](https://github.com/FlineDev/BartyCrouch/issues/63).

## [3.8.0] - 2017-05-22
### Added
- Adds new `custom-function` command line option for `code` subcommands. See #25 for details.
  Thanks to @diederich and @crystalstorm for their help to get this done!

## [3.7.1] - 2017-03-28
### Added
- Added compatibility with Xcode 8.3 and Swift 3.1.

## [3.7.0] - 2017-01-20
### Added
- Add new `unstripped` command line option for `interface` and `code` subcommands. See #49.

## [3.6.0] - 2016-12-25
### Added
- Added support for multi-line comments. See #44 for additional details.

## [3.5.0] - 2016-12-14
### Added
Adds two new options to the `code` sub command:
- **extract-loc-strings:** Uses newer tool to extract strings from code. Solves #41.
- Thanks to @fvolchyok for the PR!
- **sort-by-keys:** Sorts the translation entries by their keys. Solves #26.
See also their documentation sections in the README for additional details.

## [3.4.0] - 2016-11-21
### Added
- Adds an option to force update existing comments only via `override-comments` option on the `code` sub command.

## [3.3.0] - 2016-09-22
### Changed
- Updated project to Swift 3 and Xcode 8.

## [3.2.1] - 2016-07-02
### Changed
- Add & configure **SwiftLint linter** and fix all warnings & errors (#28)
### Fixed
- **Better error message** when no `Localizable.strings` file found (#11)
- **Escape double quotes and backslashes** in translated strings (#19)

## [3.2.0] - 2016-06-22
### Added
- Add support for **Objective-C++ '.mm' files** for subcommand `code` (#22)

## [3.1.0] - 2016-06-04
### Added
- **Ignores NSLocalizedStrings** which have ignore constant (e.g. `#bc-ignore!`) in comment (#16)

## [3.0.0] - 2016-05-05
### Added
- **Sub Commands** for updating `interfaces` / `translate` instead of options (like `-t`)
- New sub command to **update `Localizable.strings`** files from `code`
### Changed
- **Streamlined names** of options (force >> override, `-s` >> `-p`)
- **Refactored** quite some code
### Removed
- Input (`-i`), Exclude (`-e`) and Output (`-o`) options

Please have a look at the [migration guide](https://github.com/FlineDev/BartyCrouch#migration-guides) for a flawless upgrade from version 2.x.


## [2.0.0] - 2016-04-30
### Added
- **Automatic search** for files now also possible **when using `-t`** (translate) via `-s`
### Changed
- Reworked option `-a` (auto) to take a path argument and **renamed to `-s`** (search)
### Fixed
- **Improved build times** when configured with Git root folder path
### Removed
- Translating adds missing keys by default, therefore `-c` option was dropped


## [1.5.0] - 2016-04-08
### Added
- Adds support for **adding missing keys to target translations Strings files** via the `-c` command line option.
  Note that the **undocumented previous behavior** of keeping keys in translation targets that didn't exist in translation source Strings files **was dropped**. From now on only keys that also exist in the source Strings file are kept in the target files to clean up target files. For most projects this change shouldn't have any effect.


## [1.4.0] - 2016-03-14
### Added
- Add support for automatically detecting all Storyboards/XIBs
  Thanks to this change the suggested **build script is now much shorter** and will **automatically adapt** to new Interface Builder file additions. No need to keep the build script updated anymore (for incremental change updates)!

## [1.3.0] - 2016-03-03
### Added
- Add comment Base value update support (only if structure not changed from defaults)
### Changed
- Update actual translation value if same as Base (assuming comment value is previous Base value)
  See #4 for further details on the rationale for the changes made here.


## [1.2.0] - 2016-02-29
### Added
- Add option to use Base localization values when adding new keys

## [1.1.0] - 2016-02-25
### Added
- Add support for automatic machine-translation using Microsoft Translator

## [1.0.0] - 2016-02-25
### Added
- Help messages & more by using [CommandLine](https://github.com/jatoben/CommandLine)
- Shorter argument names (`--input` or `-i`, `--output` or `-o`, `--auto` or `-a`)
- Migration Guide section for major release upgrades in README
### Changed
- Improved error handling and exit codes
- Further internal improvements
