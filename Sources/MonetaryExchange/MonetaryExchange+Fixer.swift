//
//  MonetaryExchange+Fixer.swift
//  MonetaryExchange
//
//  Created by Chris Hargreaves on 04/10/2019.
//  Copyright © 2019 Software Engineering Limited. All rights reserved.
//

import Foundation

public extension Exchange {
    
    // MARK: Fixer.io Support
    
    /// Adds support for requesting data from the _Fixer.io Latest Rates_ API and being provided
    /// with an `Exchange` instance configured with this data.
    ///
    /// ### Example
    /// 
    ///     Exchange.Fixer.exchange(accessKey: "YourFixerAccessKey") { result in
    ///         switch result {
    ///             case let .success(exchange):
    ///                 // We have an Exchange value
    ///                 
    ///             case let .failure(error):
    ///                 // Something went wrong. Dig into the error.
    ///          }
    ///     }
    ///
    struct Fixer {
        
        // MARK: Fetching latest rates from Fixer
        
        /// Provides an `Exchange` value based upon the Fixer.io _Latest Rates_ API.
        ///
        /// - Parameters:
        ///     - session: A `URLSession` used to create the `URLSessionTask`. _Defaults to URLSession.shared_
        ///     - host: The host name (domain) of a _Fixer.io_ compatible API. _Defaults to the standard Fixer.io data host_
        ///     - path: The path (domain) to a _Fixer.io Latest Rates_ compatible API. _Defaults to the standard Fixer.io Latest Rates API_
        ///     - secure: Whether the request should be made over HTTP or HTTPS. The basic _Fixer.io_ plan only supports HTTP. Defaults to true (HTTPS).
        ///     - accessKey: The API access key issued by Fixer.io. _Optional if you are using a compatible API that does not require an access key._
        ///     - completion: Completes with a Swift `Result<Exchange, FixerError>` type. If the `URLSessionTask` is cancelled before completion,
        ///                   then this closure will not get called.
        ///
        /// - Returns: An optional `URLSessionTask` handling the network request for the Fixer.io API call.
        ///            If no call was made, due to error, then `nil` will be returned.
        ///
        @discardableResult
        static public func exchange(
            session: URLSession = .shared,
            host: String = defaultHost,
            path: String = detaultAPIPath,
            secure: Bool = true,
            accessKey: String?,
            completion: @escaping FixerCompletion
        ) -> URLSessionTask? {
            
            var urlComponents = URLComponents()
            urlComponents.scheme = secure ? schemeHTTPS : schemeHTTP
            urlComponents.host = host
            urlComponents.path = path
            
            if let accessKey = accessKey {
                urlComponents.queryItems = [
                    URLQueryItem(name: accessKeyQueryKey, value: accessKey)
                ]
            }

            guard let completeURL = urlComponents.url else {
                completion(.failure(.invalidURL))
                return nil
            }
            
            let request = URLRequest(url: completeURL)
            let dataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if let error = error {
                    return completion(.failure(.requestFailure(underlyingError: error)))
                }
                
                guard let data = data else {
                    return completion(.failure(.noData))
                }
                
                do {
                    return completion(.success(try JSONDecoder().decode(Exchange.self, from: data)))
                } catch {
                    let body = String(data: data, encoding: .utf8)
                    return completion(.failure(.decodingError(body: body, underlyingError: error)))
                }
            }
            
            dataTask.resume()
            
            return dataTask
        }
        
        /// - Parameters:
        ///     - result: A Swift `Result<Exchange, FixerError>` type.
        public typealias FixerCompletion = (_ result: Result<Exchange, FixerError>) -> Void
        
        // MARK: Error Handling
        
        /// Errors that can occur when requesting an `Exchange` value using the Fixer.io API
        public enum FixerError: Error {
            /// No data was returned from the API
            case noData
            /// Failed to construct a valid URL from the components provided
            case invalidURL
            /// Something went wrong when requesting data from the API. See the `underlyingError` for more information.
            case requestFailure(underlyingError: Error)
            /// Something went wrong when decoding the data from the API into an `Exchange` value. See the `underlyingError` for more information.
            case decodingError(body: String?, underlyingError: Error)
        }
        
        // MARK: Fixer.io Default Parameters
        
        /// The standard Fixer.io host for API calls: `data.fixer.io`
        public static let defaultHost = "data.fixer.io"
        
        /// The standard path for the _Latest Rates_ API: `api/latest`
        public static let detaultAPIPath = "/api/latest"
        
        /// The URL query item key used to supply the API access key: `access_key`
        public static let accessKeyQueryKey = "access_key"
        
        private static let schemeHTTPS = "https"
        private static let schemeHTTP = "http"
    }
}
