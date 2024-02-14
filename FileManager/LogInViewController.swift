//
//  LogInViewController.swift
//  FileManager
//
//  Created by netlanc on 05.02.2024.
//
import UIKit
import KeychainSwift

class LoginViewController: UIViewController {
    
    let keychain = KeychainSwift()
    var isCreatingPassword: Bool = true
    var firstPassword: String?
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите пароль"
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
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8 // закругляем углы кнопки
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
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            actionButton.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        updateActionButton()
    }
    
    private func checkPasswordExists() {
        if let _ = keychain.get("password") {
            isCreatingPassword = false
            updateActionButton() // Обновляем кнопку после проверки наличия пароля
        }
    }
    
    private func updateActionButton() {
        if isCreatingPassword {
            actionButton.setTitle("Создать пароль", for: .normal)
        } else {
            actionButton.setTitle("Войти", for: .normal)
        }
        actionButton.isHidden = false // Убираем скрытие кнопки после обновления текста
    }
    
    @objc private func actionButtonTapped() {
        guard let password = passwordTextField.text, password.count >= 4 else {
            showAlert(message: "Пароль должен быть минимум 4 символа")
            return
        }
        
        if isCreatingPassword {
            createPassword(password: password)
        } else {
            loginWithPassword(password)
        }
    }
    
    private func createPassword(password: String) {
        if firstPassword == nil {
            // Если это первый ввод пароля
            firstPassword = password
            passwordTextField.text = ""
            passwordTextField.placeholder = "Повторите пароль"
            actionButton.setTitle("Повторите пароль", for: .normal)
        } else {
            // Если пароль введен второй раз
            if password == firstPassword {
                // Если пароли совпадают, сохраняем пароль
                keychain.set(password, forKey: "password")
                isCreatingPassword = false
                updateActionButton()
                showAlert(message: "Пароль создан")
                firstPassword = nil
            } else {
                // Если пароли не совпадают, показываем ошибку
                showAlert(message: "Пароли не совпадают")
                // Сбрасываем состояние экрана до начального
                firstPassword = nil
                passwordTextField.text = ""
                passwordTextField.placeholder = "Введите пароль"
                updateActionButton()
            }
        }
    }
    
    private func loginWithPassword(_ password: String) {
        guard let savedPassword = keychain.get("password"), savedPassword == password else {
            showAlert(message: "Неверный пароль")
            return
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                let tabBarVC = TabBarController()
                window.rootViewController = tabBarVC
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Сообщение", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
