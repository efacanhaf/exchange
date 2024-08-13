//
//  MockAPIProvider.swift
//  ExchangeTests
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import Combine
@testable import Exchange

class MockAPIProvider: APIProviderProtocol {
    
    var mockRates: [String: Double] = [:]
    
    func fetch<T>(endPoint: Exchange.APIClient.EndPoint, _ type: T.Type) -> AnyPublisher<T, Error>? where T : Decodable {
        // Simulate the API response with mock data
        let exchangeRates = ExchangeRates(rates: mockRates) as! T
        return Just(exchangeRates)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
