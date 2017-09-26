//
//  ViewController.swift
//  Polyglot
//
//  Created by Ayaka Nonaka on 7/27/14.
//  Copyright (c) 2014 Ayaka Nonaka. All rights reserved.
//

import UIKit


/**
Responsible for translating text.

## Basic Usage

Create a new `Polyglot` instance.

    let translator = Polyglot(clientId: "YOUR_CLIENT_ID", clientSecret: "YOUR_CLIENT_SECRET")


You can optionally specify to & from language codes.

    translator.fromLanguage = Language.Dutch // It will automatically detect the language if you don't set this.
    translator.toLanguage = Language.English // English. This is the default.

Start translating.

    let dutch = "Ik weet het niet."
    translator.translate(dutch) { translation in
        println("\"\(dutch)\" means \"\(translation)\"")
    }

*/

class ViewController: UIViewController {

    let translator = Polyglot(clientId: "YOUR_CLIENT_ID", clientSecret: "YOUR_CLIENT_SECRET")

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var translationLabel: UILabel!

    @IBAction func didTapTranslateButton(_ sender: AnyObject) {
        guard let text = inputTextField.text else { return }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        translator.translate(text) { translation in
            if let language = self.translator.fromLanguage?.rawValue {
                self.translationLabel.text = "Translated from \(language.capitalized): \(translation)"
            }
            else {
                self.translationLabel.text = translation
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
