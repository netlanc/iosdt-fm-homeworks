//
//  PasswordViewController.swift
//  FileManager
//
//  Created by netlanc on 13.02.2024.
//

import UIKit
import KeychainSwift

class PasswordViewController: UIViewController {
    
    let keychain = KeychainSwift()
    var isCreatingPassword: Bool = true
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите пароль"
        textField.text = "1111"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect // добавляем закругленные края
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать пароль", for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue // используем цвет системной синей кнопки
        button.layer.cornerRadius = 8 // закругляем углы кнопки
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkPasswordExists()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(passwordTextField)
        view.addSubview(actionButton)
        
        
        NSLayoutConstraint.activate([
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Центрируем по горизонтали
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40), // Центрируем по вертикали и смещаем вверх
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Центрируем по горизонтали
            actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            actionButton.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor), // Задаем ширину кнопки равной ширине текстового поля
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func checkPasswordExists() {
        if let _ = keychain.get("password") {
            isCreatingPassword = false
            actionButton.setTitle("Введите пароль", for: .normal)
        }
    }
    
    @objc private func actionButtonTapped() {
        guard let password = passwordTextField.text, password.count >= 4 else {
            showAlert(message: "Пароль должен быть минимум 4 символа")
            return
        }
        
        if isCreatingPassword {
            createPassword(password: password)
        } else {
            checkPassword(password: password)
        }
    }
    
    private func createPassword(password: String) {
        keychain.set(password, forKey: "password")
        // Переходим на следующий экран
        runTabBarController()
    }
    
    private func checkPassword(password: String) {
        guard let savedPassword = keychain.get("password"), savedPassword == password else {
            showAlert(message: "Неверный пароль")
            return
        }
        runTabBarController()
        
    }
    
    private func runTabBarController() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                let tabBarVC = TabBarController()
                window.rootViewController = tabBarVC
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}



