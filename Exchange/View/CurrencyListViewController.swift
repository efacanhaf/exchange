//
//  CurrencyListViewController.swift
//  Exchange
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import UIKit
import Combine

protocol CurrencySelectedDelegate: AnyObject {
    func didSelectCurrency(_ currency: String)
}

class CurrencyListViewController: UIViewController {
    
    //MARK: - Properties
    static let cellIdentifier = "RateCell"
    
    var viewModel: CurrencyListViewModel
    var cancellables = Set<AnyCancellable>()
    var tableView: UITableView = .init()
    var searchController: UISearchController = .init()
    weak var delegate: CurrencySelectedDelegate?
    
    //MARK: - Lifecycle
    init(viewModel: CurrencyListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "This project doesn't have storyboards")
    required init?(coder: NSCoder) {
        fatalError("This project doesn't have storyboards, so this method is never called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupConstraints()
        setupUI()
        setupSearchController()
        setupTableView()
        bindViewModel()
    }
    
    func setupUI() {
        title = "Exchange"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func bindViewModel() {
        viewModel.$displayedRates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // Reload the table view with new data
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$searchQuery
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Reload table view when search query changes
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Rates"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = viewModel.isSelectable
    }
    
    func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

//MARK: - UITableViewDataSource
extension CurrencyListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayedRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
        var conf = cell.defaultContentConfiguration()
        let index = indexPath.row
        conf.text = viewModel.titleFor(index: index)
        conf.secondaryText = viewModel.detailFor(index: index)
        cell.contentConfiguration = conf
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CurrencyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.displayedRates.count - 1 {
            viewModel.loadMoreData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = viewModel.currencyForSelectedIndex(indexPath.row)
        delegate?.didSelectCurrency(currency)
        self.dismiss(animated: true)
    }
}

//MARK: - UISearchResultsUpdating
extension CurrencyListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            viewModel.searchQuery = searchText
        }
    }
}
