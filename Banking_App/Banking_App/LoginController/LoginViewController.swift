//
//  LoginViewController.swift
//  Banking_App
//
//  Created by Mahi on 15/10/25.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

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

    let loginBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()

    let signUpBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Don't have an account? Sign Up", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return btn
    }()

    let faceIDButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login with Face ID", for: .normal)
        btn.setTitleColor(.systemGreen, for: .normal)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Login"
        setupUI()
        loginWithSavedCredentials()
    }

    func setupUI() {
        let stack = UIStackView(arrangedSubviews: [emailTF, passwordTF, loginBtn, signUpBtn, faceIDButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        loginBtn.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signUpBtn.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        faceIDButton.addTarget(self, action: #selector(faceIDTapped), for: .touchUpInside)
    }

    @objc func loginTapped() {
        guard let email = emailTF.text, let password = passwordTF.text else { return }

        if LocalDataService.shared.validateUser(email: email, password: password) {
            KeychainService.save(email: email, password: password)
            LocalDataService.shared.saveLastUser(email: email)
            goToHome()
        } else {
            showAlert("Invalid Credentials")
        }
    }


    @objc func signUpTapped() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }

    @objc func faceIDTapped() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error),
           let email = LocalDataService.shared.getLastUser(),
           let creds = KeychainService.load(email: email) {

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login with Face ID") { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.emailTF.text = creds.0
                        self.passwordTF.text = creds.1
                        self.goToHome()
                    } else {
                        self.showAlert(authError?.localizedDescription ?? "Face ID Failed")
                    }
                }
            }
        } else {
            showAlert("Face ID / Touch ID not available or credentials missing.")
        }
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Bill Payment", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func goToHome() {
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
    
    func loginWithSavedCredentials() {
        guard let email = LocalDataService.shared.getLastUser(),
              let password = LocalDataService.shared.loadUsers()[email] else { return }
        
        // Optional: fill text fields
        emailTF.text = email
        passwordTF.text = password
    }

}
