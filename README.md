<p align="center">
    <img src="https://raw.githubusercontent.com/Flinesoft/BartyCrouch/stable/Logo.png"
      width=600 height=167>
</p>

<p align="center">
    <a href="https://app.bitrise.io/app/5310a5d74c63fbaf">
        <img src="https://app.bitrise.io/app/5310a5d74c63fbaf/status.svg?token=zT-LdiY1CDj1XTdzJTS5Ng&branch=stable"
             alt="Build Status">
    </a>
    <a href="https://codebeat.co/projects/github-com-flinesoft-bartycrouch">
        <img src="https://codebeat.co/badges/df0cd886-cc59-4312-b476-8932c8179a79"
             alt="codebeat badge">
    </a>
    <a href="https://github.com/Flinesoft/BartyCrouch/releases">
        <img src="https://img.shields.io/badge/Version-4.0.0-blue.svg"
             alt="Version: 4.0.0">
    </a>
    <img src="https://img.shields.io/badge/Swift-4.2-FFAC45.svg"
         alt="Swift: 4.2">
    <a href="https://github.com/Flinesoft/BartyCrouch/blob/stable/LICENSE.md">
        <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg"
              alt="License: MIT">
    </a>
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#build-script">Build Script</a>
  • <a href="#migration-guides">Migration Guides</a>
  • <a href="https://github.com/Flinesoft/BartyCrouch/issues">Issues</a>
  • <a href="#contributing">Contributing</a>
  • <a href="#license">License</a>
</p>

# BartyCrouch

BartyCrouch **incrementally updates** your Strings files from your Code *and* from Interface Builder files. "Incrementally" means that BartyCrouch will by default **keep** both your already **translated values** and even your altered comments. Additionally you can also use BartyCrouch for **machine translating** from one language to 40+ other languages. Using BartyCrouch is as easy as **running a few simple commands** from the command line what can even be **automated using a [build script](#build-script)** within your project.


## Requirements

- Xcode 10.1+ & Swift 4.2+
- Xcode Command Line Tools (see [here](http://stackoverflow.com/a/9329325/3451975) for installation instructions)

## Installation

<details>
<summary>Via [Homebrew](https://brew.sh/)</summary>

To install Bartycrouch the first time, simply run the command:

```bash
brew install bartycrouch
```

To **update** to the newest version of BartyCrouch when you have an old version already installed run:

```bash
brew upgrade bartycrouch
```
</details>

<details>
<summary>Via [Mint](https://github.com/yonaskolb/Mint)</summary>

To **install** the latest version of ProjLint simply run this command:

```bash
mint install Flinesoft/BartyCrouch
```
</details>

<details>
<summary>Via [CocoaPods](https://cocoapods.org/)</summary>

Simply add the following line to your Podfile:

```ruby
pod 'BartyCrouch'
```
</details>

## Usage

Before using BartyCrouch please **make sure you have committed your code**. Also, we highly recommend using the **build script method** described [below](#build-script).

---

`bartycrouch` accepts one of the following sub commands:

- **`update`:** Updates your `.strings` file contents.
- **`lint`:** Lints your `.strings` file contents.

### `update` subcommand

The update subcommand has the following features:

- `interfaces`: Updates `.strings` files of Storyboards & XIBs.
- `code`: Updates `Localizable.strings` file from code.
- `transform`: A convenience method call to both update `Localizable.strings` & replace code with SwiftGen/Foundation localized string call.
- `translate`: Updates missing translations in other languages.
- `normalize`: Sorts & cleans up `.strings` files.

Note that in order for the `translate` command to work, you need to specify the translator API credentialsvia environment variables named `BING_TRANSLATOR_ID` and `BING_TRANSLATOR_SECRET`.

<details><summary>Options for `interfaces`</summary>
- `defaultToBase`: Add Base translation as value to new keys.
- `ignoreEmptyStrings`: Doesn't add views with empty values.
</details>

<details><summary>Options for `code`</summary>
- `defaultsToKeys`: Add new keys both as key and value.
- `additive`: Prevents cleaning up keys not found in code.
- `customFunction`: Use alternative name to `NSLocalizedString`.
- `customLocalizableName`: Use alternative name for `Localizable.strings`.
</details>

<details><summary>Options for `translate`</summary>
- `api`: Choose which translator API to use (Google/Bing).
- `id`: The API authentication identifier.
- `secret`: The API authentication secret.
</details>

<details><summary>Options for `normalize`</summary>
- `harmonizeWithSource`: Synchronizes keys with source language.
- `sortByKeys`: Alphabetically sorts translations by their keys.
</details>

### `lint` subcommand

The lint subcommand was designed to analyze a project for typical translation issues. The current checks include:

- `duplicateKeys`: Finds duplicate keys within the same file.
- `emptyValues`: Finds empty values for any language.

Note that the `lint` command can be used both on CI and within Xcode via the build script method. On the CI your builds will fail if any issue is found. In Xcode, warnings will be shown which will point you directly to the found issue.

### `update` commands `transform` option

Copy this code to your project:

```swift
import Foundation

enum BartyCrouch {
    enum SupportedLanguage: String {
        // TODO: remove unsupported languages from the following cases list & add any missing languages
        case arabic = "ar"
        case chineseSimplified = "zh-Hans"
        case chineseTraditional = "zh-Hant"
        case english = "en"
        case french = "fr"
        case german = "de"
        case hindi = "hi"
        case italian = "it"
        case japanese = "ja"
        case korean = "ko"
        case malay = "ms"
        case portuguese = "pt-BR"
        case russian = "ru"
        case spanish = "es"
        case turkish = "tr"
    }

    static func translate(key: String, translations: [SupportedLanguage: String], comment: String? = nil) -> String {
        let typeName = String(describing: BartyCrouch.self)
        let methodName = #function

        print(
            "Warning: [BartyCrouch]",
            "Untransformed \(typeName).\(methodName) method call found with key '\(key)' and base translations '\(translations)'.",
            "Please ensure that BartyCrouch is installed and configured correctly."
        )

        // fall back in case something goes wrong with BartyCrouch transformation
        return "BC: TRANSFORMATION FAILED!"
    }
}
```

Now during development, instead of `NSLocalizedString` calls you can use `BartyCrouch.translate` and specify a key, translations (if any) and the comment. If you have configured BartyCrouch to run as a build script during build, BartyCrouch will automatically add the given key & translations to your `Localizable.strings` files and also replace the `BartyCrouch.translate` command with either `NSLocalizedString` (if `transformer` is set to `foundation` – default) or with SwiftGen's `L10n.Key.value` call (if `transformer` is set to `swiftgenStructured`).

So, for example you type this:

```swift
self.title = BartyCrouch.translate(key: "onboarding.first-page.header-title", translations: [.english: "Welcome!"])
```

Then you build your project, what will automatically add the key `onboarding.first-page.header-title` to your `Localizable.strings` files with the value in the English Strings file set to `Welcome!`. Additionally it will replace the above line with one of the following (depending on the transformer):

```swift
self.title = NSLocalizedString("onboarding.first-page.header-title", comment: "") // if transformer is set to `foundation`
self.title = L10n.Onboarding.FirstPage.headerTitle // if transformer is set to `swiftgenStructured`
```

This way you can prevent leaving the current code file you're working on just to provide initial translations for new keys you've added. You can simply specify `translations` for all languages you want to provide an initial translation for. Also you can still get the statically typed benefits from SwiftGen without needing to first write `NSLocalizedString` calls for BartyCrouch and then change them up to `L10n` calls after SwiftGen generated the appropriate files. Just write a single line and BartyCrouch will do all the work for you.

NOTE: As of version 4.0.x of BartyCrouch formatted localized Strings are not supported by this automatic feature.

### Build Script

In order to truly profit from BartyCrouch's ability to update & lint your `.strings` files you can make it a natural part of your development workflow within Xcode. In order to do this select your target, choose the `Build Phases` tab and click the + button on the top left corner of that pane. Select `New Run Script Phase` and copy the following into the text box below the `Shell: /bin/sh` of your new run script phase:

```shell
if which bartycrouch > /dev/null; then
    bartycrouch update
    bartycrouch lint
else
    echo "warning: BartyCrouch not installed, download it from https://github.com/Flinesoft/BartyCrouch"
fi
```

<img src="Images/Build-Script-Example.png">

Now BartyCrouch will be run on each build and you won't need to call it manually ever again. Additionally, all your co-workers who don't have BartyCrouch installed will see a warning with a hint how to install it. This way the entire team profits!

*Note: Please make sure you commit your code using source control regularly when using the build script method.*

Alternatively, if you've installed BartyCrouch via CocoaPods the script should look like this:

```shell
"${PODS_ROOT}/BartyCrouch/bartycrouch" update
"${PODS_ROOT}/BartyCrouch/bartycrouch" lint
```

---

### Exclude specific Views / NSLocalizedStrings from Localization

Sometimes you may want to **ignore some specific views** containing localizable texts e.g. because **their values are going to be set programmatically**.
For these cases you can simply include `#bartycrouch-ignore!` or the shorthand `#bc-ignore!` into your value within your base localized Storyboard/XIB file. Alternatively you can add `#bc-ignore!` into the field "Comment For Localizer" box in the utilities pane.

This will tell BartyCrouch to ignore this specific view when updating your `.strings` files.

Here's an example of how a base localized view in a XIB file with partly ignored strings might look like:

<img src="Images/Exclusion-Example.png">

Here's an example with the alternative comment variant:

<div style="float:left;">
	<img src="Images/IB-Comment-Exclusion-Example1.png" width="275px" height="491px">
	<img src="Images/IB-Comment-Exclusion-Example2.png" width="272px" height="195px">
</div>

You can also use `#bc-ignore!` in your `NSLocalizedString` macros comment part to ignore them so they are not added to your `Localizable.strings`. This might be helpful when you are using a `.stringsdict` file to handle pluralization (see [docs](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/StringsdictFileFormat/StringsdictFileFormat.html)).

For example you can do something like this:

```swift
func updateTimeLabel(minutes: Int) {
  String.localizedStringWithFormat(NSLocalizedString("%d minute(s) ago", comment: "pluralized and localized minutes #bc-ignore!"), minutes)
}
```

The `%d minute(s) ago` key will be taken from Localizable.stringsdict file, not from Localizable.strings.

### Configuration

BartyCrouch comes with sensible defaults that should work for most projects without issues. It is recommended to stick to the default configuration. But where customization is required, you can alter the default config file and save it in a file named `.bartycrouch.toml` within the root of your project. You can run `bartycrouch init` command to generate the default config file and start from there.

Here's the current default config:

```toml
[update]
tasks = ["interfaces", "code", "transform"]

[update.interfaces]
path = "Sources"
defaultToBase = true
ignoreEmptyStrings = true
unstripped = true

[update.code]
codePath = "Sources"
localizablePath = "Sources/SupportingFiles"
defaultToKeys = true
additive = false
customFunction = "MyOwnLocalizedString"
customLocalizableName = "MyOwnLocalizable"
unstripped = true

[update.transform]
codePath = "."
localizablePath = "."
transformer = "foundation"
typeName = "BartyCrouch"
translateMethodName = "translate"

[update.translate]
path = "Sources"
secret = "bingSecret"
sourceLocale = "de"

[update.normalize]
path = "Sources"
sourceLocale = "de"
harmonizeWithSource = false
sortByKeys = false

[lint]
path = "Sources"
duplicateKeys = false
emptyValues = false
```

## Migration Guides

See the file [MIGRATION_GUIDES.md](https://github.com/Flinesoft/BartyCrouch/blob/stable/MIGRATION_GUIDES.md).

## Contributing

See the file [CONTRIBUTING.md](https://github.com/Flinesoft/BartyCrouch/blob/stable/CONTRIBUTING.md).

## License
This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
