//
//  CurrencyListViewModel.swift
//  Exchange
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import Foundation
import Combine

class CurrencyListViewModel: ObservableObject {
    
    typealias Rate = [(key: String, value: Any)]
    
    //MARK: - Properties
    @Published var displayedRates: Rate = []
    @Published var isLoading: Bool = false
    @Published var searchQuery: String = "" {
        didSet {
            filterRates()
        }
    }
    
    public let pageSize = 10
    public var isSelectable: Bool {
        return !isRates
    }
    
    private(set) var allRates: Rate = []
    private(set) var filteredRates: Rate = []
    
    private var hasMoreData: Bool = true
    private var currentPage = 0
    private var isRates: Bool
    
    private let provider: APIProviderProtocol
    private var cancellables = [AnyCancellable?]()
    
    //MARK: - Lifecycle
    init<T: Decodable>(provider: APIProviderProtocol = APIProvider(),
                       isRates: Bool = true,
                       modelType: T.Type) {
        self.provider = provider
        self.isRates = isRates
        self.fetch(modelType: modelType)
    }
    
    //MARK: - Public funcs
    func fetch<T: Decodable>(modelType: T.Type) {
        let endPoint: APIClient.EndPoint = isRates ? .latest : .currencies
        let cancellable = provider.fetch(endPoint: endPoint, modelType)?
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print(err.localizedDescription)
                default:
                    break
                }
            } receiveValue: { response in
                if let response = response as? ExchangeRates {
                    self.allRates = response.rates.sorted { $0.key < $1.key }
                } else if let response = response as? Currencies {
                    self.allRates = response.sorted { $0.key < $1.key }
                }
                
                self.filterRates()
            }
        cancellables.append(cancellable)
    }
    
    func titleFor(index: Int) -> String {
        guard displayedRates.indices.contains(index) else { return "" }
        let item = displayedRates[index]
        return item.key
    }
    
    func detailFor(index: Int) -> String {
        guard displayedRates.indices.contains(index) else { return "" }
        let item = displayedRates[index]
        return "\(item.value)"
    }
    
    func loadMoreData() {
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        currentPage += 1
        let newRates = getPaginatedRates()
        
        displayedRates.append(contentsOf: newRates)
        hasMoreData = filteredRates.count > (displayedRates.count + pageSize)
        isLoading = false
    }
    
    func filterRates() {
        filteredRates = allRates.filter { rate in
            searchQuery.isEmpty || rate.key.lowercased().contains(searchQuery.lowercased())
        }
        
        // Reset pagination
        currentPage = 0
        displayedRates = getPaginatedRates()
        hasMoreData = filteredRates.count > pageSize
    }
    
    func currencyForSelectedIndex(_ index: Int) -> String {
        guard displayedRates.indices.contains(index) else { return "" }
        return displayedRates[index].key
    }
    
    //MARK: - Private funcs
    private func getPaginatedRates() -> Rate {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, filteredRates.count)
        return Array(filteredRates[startIndex..<endIndex])
    }
}

