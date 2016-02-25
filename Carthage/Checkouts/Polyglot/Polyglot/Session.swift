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
    var expirationTime: NSDate?

    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }

    func getAccessToken(callback: ((token: String) -> (Void))) {
        if (accessToken == nil || isExpired) {
            let url = NSURL(string: "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13")

            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"

            let bodyString = "client_id=\(clientId.urlEncoded!)&client_secret=\(clientSecret.urlEncoded!)&scope=http://api.microsofttranslator.com&grant_type=client_credentials"
            request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)

            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
                guard
                    let data = data,
                    let resultsDict = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers),
                    let expiresIn = resultsDict["expires_in"] as? NSString
                else {
                    callback(token: "")
                    return
                }
                self.expirationTime = NSDate(timeIntervalSinceNow: expiresIn.doubleValue)

                let token = resultsDict["access_token"] as! String
                self.accessToken = token

                callback(token: token)
            }

            task.resume()
        } else {
            callback(token: accessToken!)
        }
    }

    private var isExpired: Bool {
        return expirationTime?.earlierDate(NSDate()) == self.expirationTime
    }
}
