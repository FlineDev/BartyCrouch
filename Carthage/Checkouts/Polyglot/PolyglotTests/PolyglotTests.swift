// PolyglotTests.swift
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

import UIKit
import XCTest
import Polyglot
import Nocilla

class PolyglotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }

    func testInit() {
        let polyglot: Polyglot = Polyglot(clientId: "myClientId", clientSecret: "myClientSecret")
        XCTAssertNil(polyglot.fromLanguage?.rawValue)
        XCTAssertEqual(polyglot.toLanguage, Language.English)
    }
    
    func testLanguageForLocale() {
        
        let expectations: [(langCode: String, region: String?, expectedLanguage: Language?)] = [
            (langCode: "en", region: "GB",      expectedLanguage: Language.English),
            (langCode: "en", region: "APPLE",   expectedLanguage: Language.English),
            (langCode: "de", region: nil,       expectedLanguage: Language.German),
            (langCode: "de", region: "DE",      expectedLanguage: Language.German),
            (langCode: "de", region: "CH",      expectedLanguage: Language.German),
            (langCode: "nb", region: nil,       expectedLanguage: Language.Norwegian),
            (langCode: "nb", region: "NO",      expectedLanguage: Language.Norwegian),
            (langCode: "zh", region: "Hans",    expectedLanguage: Language.ChineseSimplified),
            (langCode: "zh", region: "Hant",    expectedLanguage: Language.ChineseTraditional),
            (langCode: "ja", region: nil,       expectedLanguage: Language.Japanese),
            (langCode: "sr", region: nil,       expectedLanguage: Language.Serbian),
            (langCode: "sr", region: "Latn",    expectedLanguage: Language.SerbianLatin),
            (langCode: "sr", region: "Cyrl",    expectedLanguage: Language.SerbianCyrillic),
            (langCode: "xy", region: nil,       expectedLanguage: nil),
            (langCode: "xy", region: "TEST",    expectedLanguage: nil)
        ]
        
        for (langCode, region, expectedLanguage) in expectations {
            
            let resultingLanguage = Language.languageForLocale(languageCode: langCode, region: region)
            XCTAssertEqual(resultingLanguage, expectedLanguage)
            
        }
        
    }

    func testTranslate() {
        let expectation = self.expectation(description: "translation done")

        // Stub POST access token
        stubRequest("POST", "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13")
        .withBody("client_id=myClientId&client_secret=myClientSecret&scope=http://api.microsofttranslator.com&grant_type=client_credentials".dataUsingEncoding(String.Encoding.utf8))
        .andReturn(200)
        .withHeaders(["Content-Type": "application/json"])
        .withBody("{\"access_token\":\"octocatsruleeverythingaroundme\", \"expires_in\":\"600\"}")

        // Stub GET translation
        stubRequest("GET", "http://api.microsofttranslator.com/v2/Http.svc/Translate?text=Ik%20weet%20het%20niet&to=en&from=nl")
        .withHeader("Authorization", "Bearer octocatsruleeverythingaroundme")
        .andReturn(200)
        .withBody("<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">I don't know</string>")

        let polyglot: Polyglot = Polyglot(clientId: "myClientId", clientSecret: "myClientSecret")
        polyglot.translate("Ik weet het niet") { translation in
            DispatchQueue.main.async(execute: { () -> Void in
                XCTAssertEqual(translation, "I don't know")
                expectation.fulfill()
            })
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
