//
//  NetworkService.swift
//  WaterEject
//
//  Created by Talha on 11.04.2025.
//

import Foundation
import Combine

protocol NetworkProtocol {
    func request<T: Decodable>(route: NetworkEndpointConfiguration) -> AnyPublisher<T, NetworkError>
}

final class NetworkService: NetworkProtocol {
    private let isLoggingEnabled: Bool
    
    init(isLoggingEnabled: Bool = true) {
        self.isLoggingEnabled = isLoggingEnabled
    }
    
    func request<T: Decodable>(route: NetworkEndpointConfiguration) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: route.path) else {
            return Fail(error: NetworkError.invalidUrl).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = route.method.rawValue
        request.httpBody = route.parametersBody
        request.allHTTPHeaderFields = route.headers
        request.timeoutInterval = route.timeoutInterval
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                // APPLY-CHANGE: Log the response status code and headers
                if self.isLoggingEnabled {
                    print("Response Status Code: \(httpResponse.statusCode)")
                    print("Response Headers: \(httpResponse.allHeaderFields)")
                }
                
                // APPLY-CHANGE: Check for specific status codes
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 400...499:
                    throw NetworkError.clientError(statusCode: httpResponse.statusCode)
                case 500...599:
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                default:
                    throw NetworkError.unexpectedStatusCode(statusCode: httpResponse.statusCode)
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                // APPLY-CHANGE: Enhance error logging
                if self.isLoggingEnabled {
                    print("Error: \(error)")
                }
                
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    // APPLY-CHANGE: Log more details about decoding errors
                    if self.isLoggingEnabled {
                        print("Decoding Error: \(decodingError)")
                    }
                    return .invalidData(reason: String(describing: decodingError))
                } else {
                    return .requestFailed(reason: error.localizedDescription)
                }
            }
            .handleEvents(receiveOutput: { [weak self] output in
                // APPLY-CHANGE: Log successful responses
                if self?.isLoggingEnabled == true {
                    print("Received output: \(output)")
                }
            })
            .eraseToAnyPublisher()
    }
}

// MARK: Private Methods
private extension NetworkService {
    func logJSONResponse(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print("JSON Response:")
            print(String(decoding: jsonData, as: UTF8.self))
        } else {
            print("Failed to parse JSON response")
        }
    }
}

// APPLY-CHANGE: Update NetworkError enum
enum NetworkError: Error {
    case invalidUrl
    case requestFailed(reason: String)
    case invalidResponse
    case invalidData(reason: String)
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case unexpectedStatusCode(statusCode: Int)
}

enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
}

protocol NetworkEndpointConfiguration {
    var method: HTTPMethodType { get }
    var path: String { get }
    var parametersBody: Data? { get }
    var headers: [String: String] { get }
    var timeoutInterval: TimeInterval { get }
}
