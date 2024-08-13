//
//  APIClient.swift
//  Exchange
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import Foundation
import Combine

struct APIClient {
    
    //MARK: - Static lets
    static private let timeoutInterval: TimeInterval = 30
    static private let baseURL: String = "https://api.frankfurter.app"
    
    //MARK: - Enums
    enum APIError: Error {
        case invalidBody
        case invalidEndpoint
        case invalidURL
        case emptyData
        case invalidJSON
        case invalidResponse
        case statusCode(Int)
    }
    
    enum EndPoint {
        case latest
        case currencies
        case conversion(amount: Double, from: String, to: String)
        
        var rawValue: String {
            switch self {
            case .conversion(let amount, let from, let to):
                return "latest?amount=\(amount)&from=\(from)&to=\(to)"
            default:
                return String.init(describing: self)
            }
        }
    }
    
    enum HTTPMethod: String {
        case get = "GET"
    }
    
    //MARK: - Private lets
    private let headers = [ "Content-Type": "application/json",
                            "cache-control": "no-cache"]
    
    //MARK: - Public vars
    func request<T: Decodable>(endPoint: EndPoint,
                               httpMethod: HTTPMethod) throws -> AnyPublisher<T, any Error> {
        return try requestAndValidate(endPoint: endPoint, httpMethod: httpMethod)
            .tryMap{ try validate($0.data, $0.response) }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    //MARK: - Private vars
    private func requestAndValidate(endPoint: EndPoint,
                                    httpMethod: HTTPMethod) throws -> URLSession.DataTaskPublisher {
        let request = try buildRequest(endPoint: endPoint, httpMethod: httpMethod)
        let session =  URLSession.shared
        return session.dataTaskPublisher(for: request)
    }
    
    private func validate(_ data: Data, _ response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        return data
    }
    
    private func buildRequest(endPoint: EndPoint, httpMethod: HTTPMethod) throws -> URLRequest {
        guard let url = URL(string: APIClient.baseURL + "/" + endPoint.rawValue) else {
            throw APIError.invalidEndpoint
        }
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: APIClient.timeoutInterval)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        print(url)
        return request
    }
    
}
