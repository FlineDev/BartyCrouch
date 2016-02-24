// Polyglot.swift
//
// Copyright (c) 2014 Ayaka Nonaka
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/**
    Supported languages.
*/
public enum Language: String {
    case Arabic = "ar"
    case Bulgarian = "bg"
    case Catalan = "ca"
    case ChineseSimplified = "zh-CHS"
    case ChineseTraditional = "zh-CHT"
    case Czech = "cs"
    case Danish = "da"
    case Dutch = "nl"
    case English = "en"
    case Estonian = "et"
    case Finnish = "fi"
    case French = "fr"
    case German = "de"
    case Greek = "el"
    case HaitianCreole = "ht"
    case Hebrew = "he"
    case Hindi = "hi"
    case HmongDaw = "mww"
    case Hungarian = "hu"
    case Indonesian = "id"
    case Italian = "it"
    case Japanese = "ja"
    case Klingon = "tlh"
    case KlingonPiqad = "tlh-Qaak"
    case Korean = "ko"
    case Latvian = "lv"
    case Lithuanian = "lt"
    case Malay = "ms"
    case Maltese = "mt"
    case Norwegian = "no"
    case Persian = "fa"
    case Polish = "pl"
    case Portuguese = "pt"
    case Romanian = "ro"
    case Russian = "ru"
    case Slovak = "sk"
    case Slovenian = "sl"
    case Spanish = "es"
    case Swedish = "sv"
    case Thai = "th"
    case Turkish = "tr"
    case Ukrainian = "uk"
    case Urdu = "ur"
    case Vietnamese = "vi"
    case Welsh = "cy"
}

/**
    Responsible for translating text.
*/
public class Polyglot {

    let session: Session

    /// The language to be translated from. It will automatically detect the language if you do not set this.
    public var fromLanguage: Language?

    /// The language to translate to.
    public var toLanguage: Language


    /**
        - parameter clientId: Microsoft Translator client ID.
        - parameter clientSecret: Microsoft Translator client secret.
    */
    public init(clientId: String, clientSecret: String) {
        session = Session(clientId: clientId, clientSecret: clientSecret)
        toLanguage = Language.English
    }

    /**
        Translates a given piece of text.

        - parameter text: The text to translate.
        - parameter callback: The code to be executed once the translation has completed.
    */
    public func translate(text: String, callback: ((translation: String) -> (Void))) {
        session.getAccessToken { token in
            self.fromLanguage = text.language
            let toLanguageComponent = "&to=\(self.toLanguage.rawValue.urlEncoded!)"
            let fromLanguageComponent = (self.fromLanguage != nil) ? "&from=\(self.fromLanguage!.rawValue.urlEncoded!)" : ""
            let urlString = "http://api.microsofttranslator.com/v2/Http.svc/Translate?text=\(text.urlEncoded!)\(toLanguageComponent)\(fromLanguageComponent)"

            let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            request.HTTPMethod = "GET"
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")

            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
                let translation: String
                guard
                    let data = data,
                    let xmlString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                else {
                    translation = ""
                    return
                }

                translation = self.translationFromXML(xmlString)

                defer {
                    dispatch_async(dispatch_get_main_queue()) {
                        callback(translation: translation)
                    }
                }
            }
            task.resume()
        }
    }

    private func translationFromXML(XML: String) -> String {
        let translation = XML.stringByReplacingOccurrencesOfString("<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">", withString: "")
        return translation.stringByReplacingOccurrencesOfString("</string>", withString: "")
    }
}
