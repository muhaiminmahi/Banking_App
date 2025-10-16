//
//  SignUpViewController.swift
//  Banking_App
//
//  Created by Mahi on 15/10/25.
//

import UIKit

class SignUpViewController: UIViewController {

    let emailTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        return tf
    }()

    let passwordTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        return tf
    }()

    let signUpBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()

    let loginLinkBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Already have an account? Login", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Sign Up"
        setupUI()
    }

    func setupUI() {
        let stack = UIStackView(arrangedSubviews: [emailTF, passwordTF, signUpBtn, loginLinkBtn])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        signUpBtn.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        loginLinkBtn.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    @objc func signUpTapped() {
        guard let email = emailTF.text, !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty else { return }
       
        if !isValidEmail(email) {
               showAlert(message: "Invalid Email Address")
               return
        }
        LocalDataService.shared.saveUser(email: email, password: password)
        KeychainService.save(email: email, password: password)
        LocalDataService.shared.saveLastUser(email: email)

        if let loggedInEmail = emailTF.text {
            HomeViewController.shared?.loadUserData(email: loggedInEmail)
        }
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        nav.modalPresentationStyle = .fullScreen
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }

    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let a = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
        present(a, animated: true)
    }
    
    @objc func loginTapped() {
        navigationController?.popViewController(animated: true)
    }
}
