//
//  CurrencyConversionViewModel.swift
//  Exchange
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import Foundation
import Combine
import UIKit

class CurrencyConversionViewModel: ObservableObject  {
    
    //MARK: - Properties
    static let placeHolder: String = "Select the Currency"
    
    @Published var currencies: [String] = []
    @Published var amount: Double = 0 {
        didSet {
            convert()
        }
    }
    
    let show = PassthroughSubject<UIViewController, Never>()
    let reloadSection = PassthroughSubject<Int, Never>()
    
    private let provider: APIProviderProtocol
    private var cancellables = [AnyCancellable?]()
    
    private var selectedSection: Int?
    private var result: Double?
    private var fromCurrency: String?
    private var toCurrency: String?
    
    //MARK: - Lifecycle
    init(provider: APIProviderProtocol = APIProvider()) {
        self.provider = provider
    }
    
    func selectIndex(_ index: Int) {
        if index == 0 || index == 1 {
            selectedSection = index
            let viewModel: CurrencyListViewModel = .init(isRates: false, modelType: Currencies.self)
            let vc: CurrencyListViewController = .init(viewModel: viewModel)
            vc.delegate = self
            
            show.send(vc)
        }
    }
    
    func titleFor(index: Int) -> String {
        switch index {
        case 0: return fromCurrency ?? Self.placeHolder
        case 1: return toCurrency ?? Self.placeHolder
        case 3: return result != nil ? "\(result!)" : ""
        default: return ""
        }
    }
    
    func convert() {
        guard let fromCurrency, let toCurrency else { return }
        let cancellable = provider.fetch(endPoint: .conversion(amount: amount, from: fromCurrency, to: toCurrency), ExchangeRates.self)?
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print(err.localizedDescription)
                default:
                    break
                }
            } receiveValue: { response in
                self.result = response.rates.values.first
                self.reloadSection.send(3)
            }
        cancellables.append(cancellable)
    }
}

extension CurrencyConversionViewModel: CurrencySelectedDelegate {
    func didSelectCurrency(_ currency: String) {
        guard let selectedSection else { return }
        if selectedSection == 0 {
            fromCurrency = currency
        } else if selectedSection == 1 {
            toCurrency = currency
        }
        reloadSection.send(selectedSection)
    }
}
