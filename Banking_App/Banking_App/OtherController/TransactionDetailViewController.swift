//
//  TransactionDetailViewController.swift
//  Banking_App
//
//  Created by Mahi on 15/10/25.
//

import UIKit

class TransactionDetailViewController: UIViewController {

    let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Transaction Details"
        setupUI()
    }

    func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "To: \(transaction.title)"
        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)

        let amountLabel = UILabel()
        let sign = transaction.amount < 0 ? "-" : "+"
        amountLabel.text = "Amount: \(sign)$\(abs(transaction.amount))"
        amountLabel.font = .systemFont(ofSize: 20, weight: .bold)

        let dateLabel = UILabel()
        dateLabel.text = "Date: \(transaction.date)"
        dateLabel.font = .systemFont(ofSize: 18)

        let stack = UIStackView(arrangedSubviews: [titleLabel, amountLabel, dateLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}
