//
//  SendMoneyViewController.swift
//  Banking_App
//
//  Created by Mahi on 15/10/25.
//

import UIKit

class SendMoneyViewController: UIViewController {

    let recipientTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Recipient Email"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        return tf
    }()

    let amountTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Amount ($)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        return tf
    }()

    let sendBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send Money", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Send Money"
        setupUI()
    }

    func setupUI() {
        let stack = UIStackView(arrangedSubviews: [recipientTF, amountTF, sendBtn])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        sendBtn.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }

    @objc func sendTapped() {
        guard let recipient = recipientTF.text, !recipient.isEmpty,
              let amountStr = amountTF.text, let amount = Double(amountStr) else {
            showAlert(message: "Please enter recipient and amount")
            return
        }
        
        if !isValidEmail(recipient) {
               showAlert(message: "Invalid Email Address")
               return
           }
        
       if let balance = HomeViewController.shared?.balance, balance < amount {
            showAlert(message: "Not enough funds, Please Deposit")
           return
        }
        
        let tx = Transaction(title: recipient, amount: -amount, date: today())
        HomeViewController.shared?.addTransaction(tx: tx)

        showAlert(message: "Sent $\(amount) to \(recipient)") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    
    func today() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: Date())
    }

    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let a = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
        present(a, animated: true)
    }
}
