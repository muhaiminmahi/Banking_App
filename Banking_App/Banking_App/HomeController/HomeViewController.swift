//
//  HomeViewController.swift
//  Banking_App
//
//  Created by Mahi on 15/10/25.
//

import UIKit

class HomeViewController: UIViewController {

    static var shared: HomeViewController?

    let balanceLabel = UILabel()
    let sendMoneyBtn = UIButton(type: .system)
    let transactionsBtn = UIButton(type: .system)
    let tableView = UITableView()
    
    var transactions: [Transaction] = []

    var balance: Double = 12345.67 {
        didSet {
            balanceLabel.text = "$\(String(format: "%.2f", balance))"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        HomeViewController.shared = self
        view.backgroundColor = .systemBackground
        title = "Dashboard"
        setupUI()
        loadMockTransactions()
        
        if let email = LocalDataService.shared.getLastUser() {
              self.transactions = LocalDataService.shared.loadTransactions(for: email)
              self.balance = LocalDataService.shared.loadBalance(for: email)
          }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
               title: "Deposit",
               style: .plain,
               target: self,
               action: #selector(depositMoney)
           )
        tableView.reloadData()
    }

    func setupUI() {
        balanceLabel.text = "$\(String(format: "%.2f", balance))"
        balanceLabel.font = .boldSystemFont(ofSize: 32)
        balanceLabel.textAlignment = .center

        sendMoneyBtn.setTitle("Send Money", for: .normal)
        sendMoneyBtn.backgroundColor = .systemBlue
        sendMoneyBtn.setTitleColor(.white, for: .normal)
        sendMoneyBtn.layer.cornerRadius = 10

        transactionsBtn.setTitle("Transactions", for: .normal)
        transactionsBtn.backgroundColor = .systemGreen
        transactionsBtn.setTitleColor(.white, for: .normal)
        transactionsBtn.layer.cornerRadius = 10

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutTapped))

        view.addSubview(balanceLabel)
        view.addSubview(sendMoneyBtn)
        view.addSubview(transactionsBtn)
        view.addSubview(tableView)

        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        sendMoneyBtn.translatesAutoresizingMaskIntoConstraints = false
        transactionsBtn.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            balanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            balanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            balanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            sendMoneyBtn.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 24),
            sendMoneyBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            sendMoneyBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            sendMoneyBtn.heightAnchor.constraint(equalToConstant: 50),

            transactionsBtn.topAnchor.constraint(equalTo: sendMoneyBtn.bottomAnchor, constant: 16),
            transactionsBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            transactionsBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            transactionsBtn.heightAnchor.constraint(equalToConstant: 50),

            tableView.topAnchor.constraint(equalTo: transactionsBtn.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        sendMoneyBtn.addTarget(self, action: #selector(sendMoneyTapped), for: .touchUpInside)
        transactionsBtn.addTarget(self, action: #selector(transactionsTapped), for: .touchUpInside)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    func loadMockTransactions() {
        transactions = [
            Transaction(title: "Starbucks", amount: -5.75, date: "Oct 12"),
            Transaction(title: "Salary", amount: 2500, date: "Oct 10"),
            Transaction(title: "Netflix", amount: -12.99, date: "Oct 09"),
            Transaction(title: "Apple Store", amount: -199.99, date: "Oct 08")
        ]
        tableView.reloadData()
    }

    @objc func sendMoneyTapped() {
        let sendVC = SendMoneyViewController()
        navigationController?.pushViewController(sendVC, animated: true)
    }

    @objc func transactionsTapped() {
        tableView.reloadData()
    }

    @objc func depositMoney() {
        let alert = UIAlertController(title: "Deposit Money",
                                      message: "Enter amount to deposit",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Amount"
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Deposit", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text,
               let amount = Double(text) {
                
  
                self.balance += amount
                
                if let email = LocalDataService.shared.getLastUser() {
                    LocalDataService.shared.saveBalance(self.balance, for: email)
                 }
                
                self.tableView.reloadData()
            }
        }))
        
        present(alert, animated: true)
    }

    @objc func signOutTapped() {
      
        //LocalDataService.shared.saveLastUser(email: "") // clear session

        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }


    func addTransaction(tx: Transaction) {
        // 1. Add to local array
        transactions.append(tx)
        balance += tx.amount
        // 2. Save persistently
        if let email = LocalDataService.shared.getLastUser() {
              LocalDataService.shared.saveTransactions(transactions, for: email)
              LocalDataService.shared.saveBalance(balance, for: email)
          }
        tableView.reloadData()
        
    }
    
    func loadUserData(email: String) {
        self.balance = LocalDataService.shared.loadBalance(for: email)
        self.transactions = LocalDataService.shared.loadTransactions(for: email)
        tableView.reloadData()
    }


}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tx = transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let sign = tx.amount < 0 ? "-" : "+"
        cell.textLabel?.text = "\(tx.title) \(sign)$\(abs(tx.amount)) - \(tx.date)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tx = transactions[indexPath.row]
        let detailVC = TransactionDetailViewController(transaction: tx)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
