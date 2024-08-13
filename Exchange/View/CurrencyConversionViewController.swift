//
//  CurrencyConversionViewController.swift
//  Exchange
//
//  Created by Eduardo Façanha on 13/08/2024.
//

import UIKit
import Combine

class CurrencyConversionViewController: UIViewController {

    // MARK: - Properties
    private var viewModel: CurrencyConversionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var currencies: [String] = []
    
    //MARK: - Lifecycle
    init(viewModel: CurrencyConversionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "This project doesn't have storyboards")
    required init?(coder: NSCoder) {
        fatalError("This project doesn't have storyboards")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupHierarchy()
        setupConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        bindViewModel()
    }
    
    //MARK: - Functions
    private func setupUI() {
        title = "Convert Currency"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SelectionCell")
        tableView.register(AmountTextFieldCell.self, forCellReuseIdentifier: "AmountCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
    }
    
    private func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$currencies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currencies in
                self?.currencies = currencies
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.show
            .receive(on: DispatchQueue.main)
            .sink { [weak self] vc in
                self?.showDetailViewController(vc, sender: nil)
            }
            .store(in: &cancellables)
        
        
        viewModel.reloadSection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] section in
                self?.tableView.reloadRows(at: [.init(row: 0, section: section)], with: .automatic)
            }
            .store(in: &cancellables)
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension CurrencyConversionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "From:"
        case 1: return "To:"
        case 2: return "Amount"
        case 3: return "Result"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0, 1, 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath)
            var conf = cell.defaultContentConfiguration()
            conf.text = viewModel.titleFor(index: indexPath.section)
            cell.contentConfiguration = conf
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmountCell", for: indexPath) as! AmountTextFieldCell
            cell.amountTextField.delegate = self
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectIndex(indexPath.section)
    }
}

extension CurrencyConversionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newString = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if let amount = Double(newString) {
            viewModel.amount = amount
        } else {
            viewModel.amount = 0
        }
        return true
    }
}

class AmountTextFieldCell: UITableViewCell {
    let amountTextField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(amountTextField)
        
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .numberPad
        
        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            amountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            amountTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
