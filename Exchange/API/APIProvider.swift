//
//  APIProvider.swift
//  Exchange
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import Foundation
import Combine

//MARK: - APIProviderProtocol
protocol APIProviderProtocol {
    func fetch<T: Decodable>(endPoint: APIClient.EndPoint, _ type: T.Type) -> AnyPublisher<T, Error>?
}

class APIProvider: APIProviderProtocol {
    
    //MARK: - Private lets
    private let api = APIClient()
    
    //MARK: - Public funcs
    func fetch<T: Decodable>(endPoint: APIClient.EndPoint, _ type: T.Type) -> AnyPublisher<T, Error>? {
        return try? api.request(endPoint: endPoint, httpMethod: .get)
    }
}
