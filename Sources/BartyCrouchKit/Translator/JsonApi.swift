//
//  JsonApi.swift
//  BartyCrouchKit
//
//  Created by Cihat Gündüz on 14.01.19.
//

import Foundation
import HandySwift
import MungoHealer

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol JsonApi {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    var baseUrl: URL { get }
    var path: String { get }
    var method: Method { get }
    var urlParameters: [(key: String, value: String)] { get }
    var bodyData: Data? { get }
    var headers: [String: String] { get }
}

extension JsonApi {
    func request<ResultType: Decodable>(type: ResultType.Type) -> Result<ResultType, MungoError> {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var result: Result<ResultType, MungoError>?

        var request = URLRequest(url: requestUrl())
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        if let bodyData = bodyData {
            request.httpBody = bodyData
        }

        request.httpMethod = method.rawValue

        URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            result = {
                guard error == nil else { return .failure(MungoError(source: .externalSystemUnavailable, message: error!.localizedDescription)) }
                guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                    return .failure(MungoError(source: .internalInconsistency, message: "No response received, no error."))
                }

                switch httpUrlResponse.statusCode {
                case 200 ..< 300:
                    guard let data = data else { return .failure(MungoError(source: .externalSystemBehavedUnexpectedly, message: "No data received.")) }
                    do {
                        let typedResult = try self.decoder.decode(type, from: data)
                        return .success(typedResult)
                    } catch {
                        return .failure(
                            MungoError(source: .externalSystemBehavedUnexpectedly, message: "Response data could not be converted to \(type). Error: \(error)")
                        )
                    }

                case 400 ..< 500:
                    return .failure(MungoError(source: .invalidUserInput, message: "Unexpected status code: \(httpUrlResponse.statusCode)"))

                case 500 ..< 600:
                    return .failure(MungoError(source: .externalSystemBehavedUnexpectedly, message: "Unexpected status code: \(httpUrlResponse.statusCode)"))

                default:
                    return .failure(MungoError(source: .internalInconsistency, message: "Unexpected status code: \(httpUrlResponse.statusCode)"))
                }
            }()

            dispatchGroup.leave()
        }.resume()

        dispatchGroup.wait()

        return result!
    }

    private func requestUrl() -> URL {
        var urlComponents = URLComponents(url: baseUrl.appendingPathComponent(path), resolvingAgainstBaseURL: false)!

        urlComponents.queryItems = []
        for (key, value) in urlParameters {
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }

        return urlComponents.url!
    }
}
