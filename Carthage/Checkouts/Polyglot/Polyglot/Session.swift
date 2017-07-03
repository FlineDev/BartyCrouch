// Session.swift
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

class Session {

    let clientId: String
    let clientSecret: String

    var accessToken: String?
    var expirationTime: Date?

    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }

    func getAccessToken(_ callback: @escaping ((_ token: String) -> (Void))) {
        if (accessToken == nil || isExpired) {
            let url = URL(string: "https://api.cognitive.microsoft.com/sts/v1.0/issueToken")

            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue(clientSecret, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

            
            let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
                guard
                    let data = data,
                    let responseText = String(data: data, encoding: String.Encoding.utf8)
                else {
                    callback("")
                    return
                }
                
                self.expirationTime = Date(timeIntervalSinceNow: 600)
                self.accessToken = responseText

            }) 

            task.resume()
        } else {
            callback(accessToken!)
        }
    }

    fileprivate var isExpired: Bool {
        return (expirationTime as NSDate?)?.earlierDate(Date()) == self.expirationTime
    }
}
