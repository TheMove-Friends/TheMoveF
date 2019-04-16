//
//  ApiClient.swift
//  TheMove
//
//  Created by User 2 on 3/4/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit

    public typealias JSON = [String: Any]
    public typealias HTTPHeaders = [String: String]
    
    public enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    public class APIClient {
        public func sendRequest(_ url: String,
                                method: RequestMethod,
                                headers: HTTPHeaders? = nil,
                                body: JSON? = nil,
                                completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            let url = URL(string: url)!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            
            if let headers = headers {
                urlRequest.allHTTPHeaderFields = headers
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
            
            if let body = body {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
            }
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: urlRequest) { data, response, error in
                completionHandler(data, response, error)
            }
            
            task.resume()
        }
    }

