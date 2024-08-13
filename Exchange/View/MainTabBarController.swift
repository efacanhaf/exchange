//
//  MainTabBarController.swift
//  Exchange
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import UIKit

class MainTabBarController: UITabBarController {

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currencyListViewModel = CurrencyListViewModel(provider: APIProvider(), modelType: ExchangeRates.self)
        let currencyListVC = CurrencyListViewController(viewModel: currencyListViewModel)
        let currencyListNav: UINavigationController = .init(rootViewController: currencyListVC)
        currencyListNav.navigationBar.prefersLargeTitles = true
        currencyListVC.tabBarItem = UITabBarItem(title: "Currencies", image: UIImage(systemName: "list.dash"), tag: 0)
        
        let conversionViewModel = CurrencyConversionViewModel(provider: APIProvider())
        let conversionVC = CurrencyConversionViewController(viewModel: conversionViewModel)
        let conversionNav: UINavigationController = .init(rootViewController: conversionVC)
        conversionNav.navigationBar.prefersLargeTitles = true
        conversionVC.tabBarItem = UITabBarItem(title: "Convert", image: UIImage(systemName: "arrow.right.arrow.left"), tag: 1)
        
        viewControllers = [currencyListNav, conversionNav]
    }
}
