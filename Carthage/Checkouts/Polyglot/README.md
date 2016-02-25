Polyglot
========

[![Build Status](https://travis-ci.org/ayanonagon/Polyglot.svg)](https://travis-ci.org/ayanonagon/Polyglot)

Swift wrapper around the Microsoft Translator API. By default, it translates to English from whatever language is detected.

## Installation

The easiest way to get started is to use CocoaPods. Just add the following line to your Podfile:

```ruby
pod 'Polyglot', '~> 0.3'
```

Otherwise, just include the contents of the `Polyglot` directory manually to your project.

## Basic Usage

Create a new ```Polyglot``` instance.

```swift
let translator = Polyglot(clientId: "YOUR_CLIENT_ID", clientSecret: "YOUR_CLIENT_SECRET")
```

You can optionally specify to & from language codes.

```swift
translator.fromLanguage = Language.Dutch // It will automatically detect the language if you don't set this.
translator.toLanguage = Language.English // English. This is the default.
```

Start translating.

```swift
let dutch = "Ik weet het niet."
translator.translate(dutch) { translation in
    println("\"\(dutch)\" means \"\(translation)\"")
}
```

Check out the [sample project](https://github.com/ayanonagon/Polyglot/tree/master/PolyglotSample) for a quick demo.

## Supported Languages
This list will grow as Microsoft Translator’s list grows.

| Supported languages |
| ------------------- |
| Arabic |
| Bulgarian |
| Catalan |
| Chinese (Simplified) |
| Chinese (Traditional) |
| Czech |
| Danish |
| Dutch |
| English |
| Estonian |
| Finnish |
| French |
| German |
| Greek |
| Haitian Creole |
| Hebrew |
| Hindi |
| Hmong Daw |
| Hungarian |
| Indonesian |
| Italian |
| Japanese |
| Klingon |
| Klingon pIqaD |
| Korean |
| Latvian |
| Lithuanian |
| Malay |
| Maltese |
| Norwegian |
| Persian |
| Polish |
| Portuguese |
| Romanian |
| Russian |
| Slovak |
| Slovenian |
| Spanish |
| Swedish |
| Thai |
| Turkish |
| Ukrainian |
| Urdu |
| Vietnamese |
| Welsh |

## Setting up an account for Microsoft Translator

1. Subscribe to the Microsoft Translator service [here](https://datamarket.azure.com/dataset/bing/microsofttranslator). You’ll probably need to set up a new account first. Good luck. :trollface:
2. Create a new application [here](https://datamarket.azure.com/developer/applications). This is where you will be given a client ID and client secret (which you will need for using Polyglot).

## Contributing

We’d love to see your ideas for improving this library! The best way to contribute is by submitting a pull request. We’ll do our best to respond to your patch as soon as possible. You can also submit a [new GitHub issue](https://github.com/ayanonagon/Polyglot/issues/new) if you find bugs or have questions. :octocat:

Please make sure to follow our general coding style and add test coverage for new features!
