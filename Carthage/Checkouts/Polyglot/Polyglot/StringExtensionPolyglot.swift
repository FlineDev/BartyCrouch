// StringExtension.swift
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

extension String {

    public var urlEncoded: String? {
        let urlQueryAllowedCharacterSet: NSMutableCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        urlQueryAllowedCharacterSet.removeCharactersInString("&=?+")
        return self.stringByAddingPercentEncodingWithAllowedCharacters(urlQueryAllowedCharacterSet)
    }
    
    public var language: Language? {
        if characters.count > 0 { // Prevent Index Out of Bounds in NSLinguisticTagger
            let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagSchemeLanguage], options: 0)
            tagger.string = self
            if let result = tagger.tagAtIndex(0, scheme: NSLinguisticTagSchemeLanguage, tokenRange: nil, sentenceRange: nil) {
                return Language(rawValue: result)
            }
        }
        return nil
    }
    
}
