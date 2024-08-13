//
//  ExchangeTests.swift
//  ExchangeTests
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import XCTest
import Combine
@testable import Exchange

class CurrencyListViewModelTests: XCTestCase {

    var viewModel: CurrencyListViewModel!
    var mockProvider: MockAPIProvider!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockProvider = MockAPIProvider()
        viewModel = CurrencyListViewModel(provider: mockProvider, modelType: ExchangeRates.self)
    }

    func testFetchSymbols() {
        // Given
        let expectedRates: [String: Double] = [
            "USD": 1.1,
            "EUR": 1.0
        ]
        mockProvider.mockRates = expectedRates
        
        // When
        let expectation = XCTestExpectation(description: "Fetch symbols")
        
        viewModel.fetch(modelType: ExchangeRates.self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Then
            XCTAssertEqual(self.viewModel.allRates.count, expectedRates.count)
            XCTAssertEqual(self.viewModel.allRates.first?.key, "EUR")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testFilterRates() {
        // Given
        let rates: [String: Double] = [
            "USD": 1.1,
            "EUR": 1.0,
            "GBP": 0.85
        ]
        mockProvider.mockRates = rates
        
        // When
        viewModel.fetch(modelType: ExchangeRates.self) // Ensure allRates is populated
        viewModel.searchQuery = "US"
        
        // Then
        XCTAssertEqual(viewModel.displayedRates.count, 1)
        XCTAssertEqual(viewModel.displayedRates.first?.key, "USD")
    }
    
    func testLoadMoreData() {
        // Given
        let rates: [String: Double] = [
            "USD": 1.1,
            "EUR": 1.0,
            "GBP": 0.85,
            "JPY": 110.0,
            "AUD": 1.5
        ]
        mockProvider.mockRates = rates
        
        // When
        viewModel.fetch(modelType: ExchangeRates.self) // Ensure allRates is populated
        viewModel.loadMoreData()
        
        // Then
        XCTAssertEqual(viewModel.displayedRates.count, min(viewModel.pageSize, rates.count))
    }
}
