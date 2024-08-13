//
//  CurrencyListViewControllerTests.swift
//  ExchangeTests
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import XCTest
import Combine
@testable import Exchange

class CurrencyListViewControllerTests: XCTestCase {

    var viewModel: CurrencyListViewModel!
    var viewController: CurrencyListViewController!
    var mockProvider: MockAPIProvider!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockProvider = MockAPIProvider()
        viewModel = CurrencyListViewModel(provider: mockProvider, modelType: ExchangeRates.self)
        viewController = CurrencyListViewController(viewModel: viewModel)
        
        // Load the view hierarchy
        _ = viewController.view
    }

    func testInitialState() {
        // Given
        let rates: [String: Double] = [
            "USD": 1.1,
            "EUR": 1.0
        ]
        mockProvider.mockRates = rates
        
        // When
        viewModel.fetch(modelType: ExchangeRates.self)
        // Allow some time for asynchronous fetch
        let expectation = XCTestExpectation(description: "Initial state after fetch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Then
            XCTAssertEqual(self.viewController.tableView.numberOfRows(inSection: 0), 2)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSearchFunctionality() {
        // Given
        let rates: [String: Double] = [
            "USD": 1.1,
            "EUR": 1.0,
            "GBP": 0.85
        ]
        mockProvider.mockRates = rates
        viewModel.fetch(modelType: ExchangeRates.self)
        
        // When
        viewModel.searchQuery = "US"
        
        // Then
        XCTAssertEqual(viewModel.displayedRates.count, 1)
        let title = viewModel.titleFor(index: .zero)
        XCTAssertEqual(title, "USD")
        let rate = viewModel.detailFor(index: .zero)
        XCTAssertEqual(rate, "1.1")
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
        viewModel.fetch(modelType: ExchangeRates.self)
        viewModel.loadMoreData()
        
        // Then
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), min(viewModel.pageSize, rates.count))
    }
    
    func testSearchBarInteraction() {
        // Given
        let rates: [String: Double] = [
            "USD": 1.1,
            "EUR": 1.0,
            "GBP": 0.85
        ]
        mockProvider.mockRates = rates
        viewModel.fetch(modelType: ExchangeRates.self)
        
        // When
        let searchBar = viewController.searchController.searchBar
        searchBar.text = "GBP"
        viewController.updateSearchResults(for: viewController.searchController)
        
        // Then
        XCTAssertEqual(viewModel.displayedRates.count, 1)
        let title = viewModel.titleFor(index: .zero)
        XCTAssertEqual(title, "GBP")
        let rate = viewModel.detailFor(index: .zero)
        XCTAssertEqual(rate, "0.85")
    }
    
    func testPaginationOnScroll() {
        // Given
        let rates: [String: Double] = [
            "USD": 1.1,
            "EUR": 1.0,
            "GBP": 0.85,
            "JPY": 110.0,
            "AUD": 1.5,
            "CAD": 1.2
        ]
        mockProvider.mockRates = rates
        viewModel.fetch(modelType: ExchangeRates.self)
        
        // Simulate scrolling to the bottom of the table view
        viewModel.loadMoreData()
        
        // When
        viewController.tableView.delegate?.scrollViewDidScroll?(viewController.tableView)
        
        // Then
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), min(viewModel.pageSize * 2, rates.count))
    }
}
